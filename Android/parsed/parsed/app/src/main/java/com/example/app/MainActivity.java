/*
 * Project:		parsed
 *
 * Package:		app
 *
 * Author:		aaronburke
 *
 * Date:		 	4 11, 2014
 */

package com.example.app;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.ActionMode;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MainActivity extends ListActivity implements ParseQueryAdapter.OnQueryLoadListener<ParseObject>,
        AdapterView.OnItemLongClickListener {

    Context mContext;
    EntryListAdapter entryListAdapter;
    CachedEntryListAdapter cachedEntryListAdapter;

    private static final String cache_file = "entry_data";
    private static final String offline_save_file = "offline_save_data";

    private static final String data_file = "entry_data";

    List<Entry> cachedEntries;
    List<Entry> offlineSavedArray;

    private ActionMode mActionMode;

    int itemPosition;
    View itemRow;

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mContext = this;

        try {
            offlineSavedArray = (List<Entry>) EntryManager.readObject(mContext, offline_save_file);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        if (offlineSavedArray == null) {
            offlineSavedArray = new ArrayList<Entry>();
        }

        Boolean checkUpdates = isUpdateAvailable(mContext);

        if (!checkUpdates) {
            // Retrieve the list from internal storage
            try {
                cachedEntries = (List<Entry>) EntryManager.readObject(mContext, data_file);
                cachedEntryListAdapter = new CachedEntryListAdapter(mContext, cachedEntries);
                setListAdapter(cachedEntryListAdapter);

            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }



        getListView().setOnItemLongClickListener(this);

        // Polling method to check server for new data
        final Handler handler = new Handler();
        Runnable runnable = new Runnable() {

            @Override
            public void run() {
                try{
                    Log.i("test","this will run every 60s");
                    Boolean status = ConnectionStatus.getNetworkStatus(mContext);
                    if (status) {
                        isUpdateAvailable(mContext);
                        if (offlineSavedArray.size() > 0) {
                            updateParseWithOfflineData(mContext);
                        }
                    } else {

                    }
                }
                catch (Exception e) {
                    // TODO: handle exception
                }
                finally{
                    //also call the same runnable
                    handler.postDelayed(this, 60*1000);
                }
            }
        };
        handler.postDelayed(runnable, 60*1000);

    }

    private BroadcastReceiver connectivityReceiver = new BroadcastReceiver () {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
                Boolean status = ConnectionStatus.getNetworkStatus(mContext);
                if (status) {
                    Log.i("CONN_STATUS", "CONNECTED!");

                }else {
                    Log.i("CONN_STATUS", "DISCONNECTED!");
                }
            }
        }
    };

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(connectivityReceiver);
    }

    @Override
    protected void onResume() {
        super.onResume();
        IntentFilter netFilter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
        registerReceiver(connectivityReceiver, netFilter);
    }

    private ActionMode.Callback mActionModeCallback = new ActionMode.Callback() {

        // Called when the action mode is created; startActionMode() was called
        @Override
        public boolean onCreateActionMode(ActionMode mode, Menu menu) {
            // Inflate a menu resource providing context menu items
            MenuInflater inflater = mode.getMenuInflater();
            inflater.inflate(R.menu.delete_context_menu, menu);
            return true;
        }

        // Called each time the action mode is shown. Always called after onCreateActionMode, but
        // may be called multiple times if the mode is invalidated.
        @Override
        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
            return false; // Return false if nothing is done
        }

        // Called when the user selects a contextual menu item
        @Override
        public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
            switch (item.getItemId()) {
                case R.id.item_delete:
                    Log.i("EDIT MENU", "Delete Selected.");
                    deleteEntryData(cachedEntries.get(itemPosition), mContext);
                    mode.finish(); // Action picked, so close the CAB
                    return true;

                case R.id.item_edit:
                    Log.i("EDIT MENU", "Edit Selected.");
                    editEntry(itemRow, itemPosition);
                    mode.finish(); // Action picked, so close the CAB
                    return true;

                default:
                    return false;
            }
        }

        // Called when the user exits the action mode
        @Override
        public void onDestroyActionMode(ActionMode mode) {
            mActionMode = null;
        }
    };


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_add:
                Log.i("MAIN", "New Entry Selected.");
                createNewEntry();
                return true;

            case R.id.action_logout:
                Log.i("MAIN", "Log Out Selected.");
                ParseUser.logOut();
                Intent intent = new Intent(mContext, LoginActivity.class);
                startActivity(intent);
                // Removes activity from the stack so we can not navigate back
                finish();
                return true;

        }
        return super.onOptionsItemSelected(item);
    }


    @Override
    public void onLoading() {

    }

    @Override
    public void onLoaded(List<ParseObject> parseObjects, Exception e) {
        Log.i("LIST SIZE RETURN = ", Integer.toString(parseObjects.size()));

        // Create cached list of entries from parse.com and write to file if cache is empty
        if (cachedEntries == null) {
            cachedEntries = new ArrayList<Entry>();
            for (ParseObject entry : parseObjects ) {
                cachedEntries.add(new Entry(entry.getString("name"),
                        entry.getString("message"),
                        entry.getNumber("number"),
                        entry.getObjectId(),
                        entry.getString("UUID")));
            }

            if (cachedEntries != null) {
                try {
                    EntryManager.writeObject(mContext,data_file,cachedEntries);
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
        }

    }

    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        Log.i("ListLongClick", "Activated onItemLongClick");


        if (mActionMode != null) {
            return false;
        }
        itemPosition = position;
        itemRow = view;
        // Start the CAB using the ActionMode.Callback defined above
        mActionMode = this.startActionMode(mActionModeCallback);
        view.setSelected(true);

        return true;
    }

    public void createNewEntry() {
        AlertDialog.Builder projectBuilder = new AlertDialog.Builder(mContext);
        projectBuilder.setTitle(R.string.action_new);
        LayoutInflater inflater = (LayoutInflater) mContext.getSystemService( Context.LAYOUT_INFLATER_SERVICE );
        final View view = inflater.inflate(R.layout.create_entry, null);

        final TextView errorMessage = (TextView) view.findViewById(R.id.entry_error);

        final EditText entryName = (EditText) view.findViewById(R.id.entry_name);
        entryName.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });
        final EditText entryMessage = (EditText) view.findViewById(R.id.entry_message);
        entryMessage.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });
        final EditText entryNumber = (EditText) view.findViewById(R.id.entry_number);
        entryNumber.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });

        projectBuilder.setView(view)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {

                    }
                })
                .setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {

                    }
                });
        final AlertDialog dialog = projectBuilder.create();
        dialog.show();

        //noinspection ConstantConditions
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v){

                entryName.clearFocus();
                entryMessage.clearFocus();
                entryNumber.clearFocus();

                Boolean valid = false;

                if (entryName.getText().toString().isEmpty() || entryMessage.getText().toString().isEmpty() || entryNumber.getText().toString().isEmpty() ) {
                    Log.i("Save Entry", "Inputs can't be empty!");
                    errorMessage.setText("Inputs can't be empty!");
                    errorMessage.setVisibility(View.VISIBLE);

                } else if (!entryNumber.getText().toString().isEmpty()) {
                    try {
                        int num = Integer.parseInt(entryNumber.getText().toString());
                        valid = true;
                    } catch (NumberFormatException e) {
                        errorMessage.setText("Input a valid number!");
                        errorMessage.setVisibility(View.VISIBLE);
                        valid = false;
                    }
                }

                if (valid) {
                    String name = entryName.getText().toString();
                    String message = entryMessage.getText().toString();
                    int number = Integer.parseInt(entryNumber.getText().toString());

                    Entry entryToSave = new Entry(name, message, number);
                    saveToParse(entryToSave, mContext);


                }
                dialog.dismiss();
            }

        });
    }

    public void editEntry(final View row, final int position) {
        AlertDialog.Builder projectBuilder = new AlertDialog.Builder(mContext);
        projectBuilder.setTitle(R.string.action_new);
        LayoutInflater inflater = (LayoutInflater) mContext.getSystemService( Context.LAYOUT_INFLATER_SERVICE );
        final View view = inflater.inflate(R.layout.create_entry, null);

        final Entry entryToEdit = cachedEntries.get(position);

        final TextView errorMessage = (TextView) view.findViewById(R.id.entry_error);

        final EditText entryName = (EditText) view.findViewById(R.id.entry_name);
        entryName.setText(entryToEdit.getName());
        entryName.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });

        final EditText entryMessage = (EditText) view.findViewById(R.id.entry_message);
        entryMessage.setText(entryToEdit.getMessage());
        entryMessage.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });

        final EditText entryNumber = (EditText) view.findViewById(R.id.entry_number);
        entryNumber.setText(entryToEdit.getNumber().toString());
        entryNumber.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                errorMessage.setVisibility(View.INVISIBLE);
            }
        });

        projectBuilder.setView(view)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {

                    }
                })
                .setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {

                    }
                });
        final AlertDialog dialog = projectBuilder.create();
        dialog.show();

        //noinspection ConstantConditions
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v){

                //Boolean status = ConnectionStatus.getNetworkStatus(mContext);
                Boolean valid = false;

                if (entryName.getText().toString().isEmpty() || entryMessage.getText().toString().isEmpty() || entryNumber.getText().toString().isEmpty() ) {
                    Log.i("Save Entry", "Inputs can't be empty!");
                    errorMessage.setText("Inputs can't be empty!");
                    errorMessage.setVisibility(View.VISIBLE);

                } else if (!entryNumber.getText().toString().isEmpty()) {
                    try {
                        int num = Integer.parseInt(entryNumber.getText().toString());
                        valid = true;
                    } catch (NumberFormatException e) {
                        errorMessage.setText("Input a valid number!");
                        errorMessage.setVisibility(View.VISIBLE);
                        valid = false;
                    }


                }

                if (valid) {
                    entryToEdit.setName(entryName.getText().toString());
                    entryToEdit.setMessage(entryMessage.getText().toString());
                    entryToEdit.setNumber((Number) Integer.parseInt(entryNumber.getText().toString()));

                    try {
                        // Write to local cache
                        EntryManager.writeObject(mContext,data_file,cachedEntries);
                        // Save to Parse.com
                        updateToParse(entryToEdit, mContext);

                        cachedEntryListAdapter.notifyDataSetChanged();
                        setModifiedTime(mContext);
                        dialog.dismiss();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

        });
    }

    public void updateToParse(final Entry entry, final Context mContext) {
        Boolean status = ConnectionStatus.getNetworkStatus(mContext);
        for (Entry cachedEntry : cachedEntries) {
            if (cachedEntry.getUUID().equals(entry.getUUID())) {
                cachedEntry.setName(entry.getName());
                cachedEntry.setMessage(entry.getMessage());
                cachedEntry.setNumber(entry.getNumber());
            }
        }


        if (status) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
            query.getInBackground(entry.getParseObjId(), new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (e == null) {
                        object.put("message", entry.getMessage());
                        object.put("name", entry.getName());
                        object.put("number", entry.getNumber());
                        object.saveInBackground(new SaveCallback() {
                            public void done(ParseException e) {
                                if (e == null) {
                                    setModifiedTime(mContext);
                                }
                            }
                        });

                    }
                }
            });
        } else {
            for (Entry entryOfflineSaved : offlineSavedArray) {
                if (entryOfflineSaved.getUUID().equals(entry.getUUID())) {
                    offlineSavedArray.remove(entryOfflineSaved);
                }
            }
            setModifiedTime(mContext);
            offlineSavedArray.add(entry);
            try {
                EntryManager.writeObject(mContext, offline_save_file, offlineSavedArray);
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }

    public void saveToParse(final Entry entry, final Context mContext) {
        Boolean status = ConnectionStatus.getNetworkStatus(mContext);

        cachedEntries.add(entry);
        if (cachedEntryListAdapter == null) {
            cachedEntryListAdapter = new CachedEntryListAdapter(mContext, cachedEntries);
            setListAdapter(cachedEntryListAdapter);
        } else {
            cachedEntryListAdapter.notifyDataSetChanged();
        }

        try {
            EntryManager.writeObject(mContext, data_file, cachedEntries);
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (status) {

            ParseObject entryToSave = new ParseObject("Entry");
            entryToSave.put("name", entry.getName());
            entryToSave.put("message", entry.getMessage());
            entryToSave.put("number", entry.getNumber());
            entryToSave.put("UUID", entry.getUUID());

            entryToSave.saveInBackground(new SaveCallback() {
                public void done(ParseException e) {
                    if (e == null) {
                        ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
                        query.whereEqualTo("UUID", entry.getUUID());
                        query.getFirstInBackground(new GetCallback<ParseObject>() {
                            public void done(ParseObject object, ParseException e) {
                                if (object != null) {
                                    updateCacheIdData(object, mContext);
                                    setModifiedTime(mContext);
                                }
                            }
                        });
                    }
                }
            });

        } else {
            offlineSavedArray.add(entry);
            try {
                //EntryManager.writeObject(mContext, cache_file, cachedEntries);
                EntryManager.writeObject(mContext, offline_save_file, offlineSavedArray);
                setModifiedTime(mContext);
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }

    public void deleteEntryData(Entry entry, final Context mContext) {

        Log.i("UUID = " , entry.getUUID());
        Boolean status = ConnectionStatus.getNetworkStatus(mContext);
        if (status) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
            query.whereContains("UUID", entry.getUUID());
            query.getInBackground(entry.getParseObjId(), new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (e == null) {
                        Boolean statusCheck = ConnectionStatus.getNetworkStatus(mContext);
                        if (statusCheck) {

                            object.deleteInBackground();

                        } else {
                            object.deleteEventually();
                        }
                        setModifiedTime(mContext);
                    }
                }
            });
        } else {
            setModifiedTime(mContext);
        }

        cachedEntries.remove(entry);
        cachedEntryListAdapter.notifyDataSetChanged();
        try {
            EntryManager.writeObject(mContext, cache_file, cachedEntries);
        } catch (IOException e) {
            e.printStackTrace();
        }


    }

    public void updateCacheIdData(ParseObject entry, Context mContext) {
        for (Entry cachedEntry : cachedEntries) {
            if (entry.getString("UUID").equals(cachedEntry.getUUID())) {
                cachedEntry.setParseObjId(entry.getObjectId());
            }
        }
        try {
            EntryManager.writeObject(mContext, cache_file,cachedEntries);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void setModifiedTime(Context mContext) {
        Date date = new Date();
        final long epoch = date.getTime()/1000;

        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
        if (status) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
            query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
            query.getFirstInBackground(new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (object != null) {
                        object.put("updateTime", epoch);
                        object.saveInBackground();
                    } else {
                        ParseObject updateStatusObj = new ParseObject("Status");
                        updateStatusObj.put("userId", ParseUser.getCurrentUser().getObjectId());
                        updateStatusObj.put("updateTime", epoch);
                        updateStatusObj.setACL(new ParseACL(ParseUser.getCurrentUser()));
                        updateStatusObj.saveInBackground();
                    }
                }
            });
        }
        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putLong("updateTime", epoch);
        editor.commit();
    }

    // Implemented this method to remove parse saveEventually
    // Updates parse.com with the correct offline data immediately when network returns
    // Parse.com saveEventually proved unreliable
    public void updateParseWithOfflineData(final Context mContext) {
        List<ParseObject> parseObjects = new ArrayList<ParseObject>();
        if (offlineSavedArray.size() > 0) {
            for (Entry entry : offlineSavedArray) {
                ParseObject entryParse = new ParseObject("Entry");
                if (entry.getParseObjId().length() != 0) {
                    entryParse.setObjectId(entry.getParseObjId());
                }
                entryParse.put("message", entry.getMessage());
                entryParse.put("name", entry.getName());
                entryParse.put("number", entry.getNumber());
                entryParse.put("UUID", entry.getUUID());
                parseObjects.add(entryParse);
            }
            ParseObject.saveAllInBackground(parseObjects,new SaveCallback() {
                public void done(ParseException e) {
                    if (e == null) {
                        offlineSavedArray.clear();
                        try {
                            EntryManager.writeObject(mContext, offline_save_file, offlineSavedArray);
                        } catch (IOException e1) {
                            e1.printStackTrace();
                        }
                        ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
                        query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
                        query.getFirstInBackground(new GetCallback<ParseObject>() {
                            public void done(ParseObject object, ParseException e) {
                                SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
                                long time = preferences.getLong("updateTime", 0);
                                if (object != null) {
                                    object.put("updateTime", time);
                                    object.saveInBackground();
                                } else {
                                    ParseObject updateStatusObj = new ParseObject("Status");
                                    updateStatusObj.put("userId", ParseUser.getCurrentUser().getObjectId());
                                    updateStatusObj.put("updateTime", time);
                                    updateStatusObj.setACL(new ParseACL(ParseUser.getCurrentUser()));
                                    updateStatusObj.saveInBackground();
                                }
                            }
                        });

                    }
                }
            });
        }



    }

    public Boolean isUpdateAvailable(Context mContext) {
        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
        long updateTime = preferences.getLong("updateTime", 0);

        if (updateTime != 0) {
            final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
            if (status) {
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
                query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
                try {
                    ParseObject updateStatus = query.getFirst();
                    if (updateStatus != null) {
                        long numFromParse = updateStatus.getLong("updateTime");
                        Log.i("Stored time = ", String.valueOf(updateTime));
                        Log.i("Parse time = ", String.valueOf(numFromParse));
                        if (updateTime < numFromParse) {
                            newDataUpdate(mContext);
                            return true;
                        } else {
                            return false;
                        }
                    }
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }

        } else {
            newDataUpdate(mContext);
        }
        return false;
    }

    public void newDataUpdate(Context mContext) {
        if (cachedEntries != null) {
            cachedEntries.clear();
        }
        if (offlineSavedArray != null) {
            offlineSavedArray.clear();
        }

        try {
            EntryManager.writeObject(mContext, offline_save_file, offlineSavedArray);
            EntryManager.writeObject(mContext, cache_file, cachedEntries);
        } catch (IOException e) {
            e.printStackTrace();
        }
        updateLocalUpdateTime(mContext);
        createDataFromParse();
    }

    public static void updateLocalUpdateTime(final Context mContext) {
        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
        if (status) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
            query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
            query.getFirstInBackground(new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (object != null) {
                        long time = object.getLong("updateTime");
                        Log.i("updateLocalUpdateTime", "Time from Parse = " + String.valueOf(time));
                        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = preferences.edit();
                        editor.putLong("updateTime", time);
                        editor.commit();
                    }
                }
            });
        }
    }

    public void createDataFromParse(){
        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
        if (status) {

            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, ParseException e) {
                    if (e == null) {
                        for (ParseObject object : objects) {
                            Entry entry = new Entry(object.getString("name"), object.getString("message"), object.getNumber("number"), object.getObjectId(), object.getString("UUID"));
                            if (cachedEntries == null) {
                                cachedEntries = new ArrayList<Entry>();
                            }
                            cachedEntries.add(entry);
                            cachedEntryListAdapter = new CachedEntryListAdapter(mContext, cachedEntries);
                            setListAdapter(cachedEntryListAdapter);
                            try {
                                EntryManager.writeObject(mContext,data_file,cachedEntries);
                            } catch (IOException e1) {
                                e1.printStackTrace();
                            }
                        }
                    }

                }
            });

            ParseQuery<ParseObject> query2 = ParseQuery.getQuery("Status");
            query2.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
            query2.getFirstInBackground(new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {

                    if (object != null) {
                        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = preferences.edit();
                        editor.putLong("updateTime", object.getLong("updateTime"));
                        Log.i("updateTime = ", String.valueOf(object.getLong("updateTime")));
                        editor.commit();
                    }
                }
            });

        }
    }


}
