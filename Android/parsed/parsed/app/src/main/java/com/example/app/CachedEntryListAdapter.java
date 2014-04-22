/*
 * Project:		parsed
 *
 * Package:		app
 *
 * Author:		aaronburke
 *
 * Date:		 	4 18, 2014
 */

package com.example.app;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.List;

/**
 * Created by aaronburke on 4/18/14.
 */
public class CachedEntryListAdapter extends ArrayAdapter<Entry> {

    private final Context mContext;
    private final List<Entry> entries;

    public CachedEntryListAdapter(Context context, List<Entry> entries) {
        super(context, R.layout.list_item_layout, entries);
        this.mContext = context;
        this.entries = entries;
    }

    public List<Entry> getItems() {
        return entries;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View v = convertView;

        if (v == null) {

            LayoutInflater vi;
            vi = LayoutInflater.from(getContext());
            v = vi.inflate(R.layout.list_item_layout, null);

        }

        TextView userName = (TextView) v.findViewById(R.id.name);
        userName.setText(entries.get(position).getName());
        //Log.i("QUERY", "Name = " + entries.get(position).getName());

        TextView message = (TextView) v.findViewById(R.id.message);
        message.setText(entries.get(position).getMessage());
        //Log.i("QUERY", "Message = " + entries.get(position).getMessage());

        TextView projectStatus = (TextView) v.findViewById(R.id.random_number);
        projectStatus.setText(entries.get(position).getNumber().toString());
        //Log.i("QUERY", "RandomNum = " + entries.get(position).getNumber().toString());


        return v;
    }

}
