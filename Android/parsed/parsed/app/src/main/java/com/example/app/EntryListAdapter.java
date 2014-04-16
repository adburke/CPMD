/*
 * Project:		parsed
 *
 * Package:		app
 *
 * Author:		aaronburke
 *
 * Date:		 	4 15, 2014
 */

package com.example.app;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;

/**
 * Created by aaronburke on 4/15/14.
 */
public class EntryListAdapter extends ParseQueryAdapter<ParseObject> {

    Context mContext;

    public EntryListAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {

                ParseQuery query = new ParseQuery("Entry");
                //query.whereEqualTo("createdBy", ParseUser.getCurrentUser());
                Log.i("QUERY", "Query = " + query);
                return query;

            }
        });
        mContext = context;
        Log.i("PARSEADAPTER", "context = " + mContext);
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public View getItemView(ParseObject object, View v, ViewGroup parent) {
        Log.i("getItemView", "fired");
        if (v == null) {
            v = View.inflate(mContext, R.layout.list_item_layout, null);
            Log.i("PARSEADAPTER", "Layout Inflated");
        }
        super.getItemView(object, v, parent);

        TextView userName = (TextView) v.findViewById(R.id.name);
        userName.setText(object.getString("name"));
        Log.i("QUERY", "Name = " + object.getString("name"));

        TextView message = (TextView) v.findViewById(R.id.message);
        message.setText(object.getString("message"));
        Log.i("QUERY", "Message = " + object.getString("message"));

        TextView projectStatus = (TextView) v.findViewById(R.id.random_number);
        projectStatus.setText(object.getNumber("number").toString());
        Log.i("QUERY", "RandomNum = " + object.getString("status"));

        return v;
    }
}
