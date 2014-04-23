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
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.ActionMode;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQueryAdapter;
import com.parse.SaveCallback;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends ListActivity implements ParseQueryAdapter.OnQueryLoadListener<ParseObject>, AdapterView.OnItemLongClickListener {

    Context mContext;
    EntryListAdapter entryListAdapter;
    CachedEntryListAdapter cachedEntryListAdapter;

    private static final String data_file = "entry_data";
    List<Entry> cachedEntries;

    private ActionMode mActionMode;

    int itemPosition;
    View itemRow;

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mContext = this;

        // Retrieve the list from internal storage
        try {
            cachedEntries = (List<Entry>) EntryManager.readObject(mContext, data_file);
            cachedEntryListAdapter = new CachedEntryListAdapter(mContext, cachedEntries);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        // If internal storage is empty pull from parse.com
        if (cachedEntries == null) {
            entryListAdapter = new EntryListAdapter(mContext);
            entryListAdapter.addOnQueryLoadListener(this);
            setListAdapter(entryListAdapter);
            entryListAdapter.loadObjects();
        } else {
            setListAdapter(cachedEntryListAdapter);

        }

        getListView().setOnItemLongClickListener(this);

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
                    //removeRow(itemRow, itemPosition);
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
                Log.i("MAIN", "Logout selected");

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
               

                if (entryName.getText().toString().isEmpty() || entryMessage.getText().toString().isEmpty() || entryNumber.getText().toString().isEmpty() ) {
                    Log.i("Save Entry", "Inputs can't be empty!");
                    errorMessage.setText("Inputs can't be empty!");
                    errorMessage.setVisibility(View.VISIBLE);

                } else if (!entryNumber.getText().toString().isEmpty()) {
                    try {
                        int num = Integer.parseInt(entryNumber.getText().toString());
                    } catch (NumberFormatException e) {
                        errorMessage.setText("Input a valid number!");
                        errorMessage.setVisibility(View.VISIBLE);
                    }


                }
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

                if (entryName.getText().toString().isEmpty() || entryMessage.getText().toString().isEmpty() || entryNumber.getText().toString().isEmpty() ) {
                    Log.i("Save Entry", "Inputs can't be empty!");
                    errorMessage.setText("Inputs can't be empty!");
                    errorMessage.setVisibility(View.VISIBLE);

                } else if (!entryNumber.getText().toString().isEmpty()) {
                    try {
                        int num = Integer.parseInt(entryNumber.getText().toString());
                    } catch (NumberFormatException e) {
                        errorMessage.setText("Input a valid number!");
                        errorMessage.setVisibility(View.VISIBLE);
                    }


                }
            }

        });
    }

}
