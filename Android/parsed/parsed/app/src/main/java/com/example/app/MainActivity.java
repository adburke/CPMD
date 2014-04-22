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
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.parse.ParseObject;
import com.parse.ParseQueryAdapter;

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
                    //removeRow(itemRow, itemPosition);
                    mode.finish(); // Action picked, so close the CAB
                    return true;

                case R.id.item_edit:
                    //editProject();
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
}
