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

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.List;

/**
 * Created by aaronburke on 4/15/14.
 */
public class EntryManager {

    private static final String cache_file = "entry_data";
    private static final String offline_save_filie = "offline_save_data";

    // Singleton Creation
    private static EntryManager m_instance;
    public static List<Entry> cachedEntries;
    public static List<Entry> offlineSavedArray;

    private EntryManager(){
        // Constructor empty for singleton
    }
    // Check if m_instance is null, if so create the singleton, otherwise it is created already
    public static EntryManager getMinstance() {
        if (m_instance == null) {
            m_instance = new EntryManager();
        }
        return m_instance;
    }

    public static void writeObject(Context context, String filename, Object object) throws IOException {
        FileOutputStream fos = context.openFileOutput(filename, Context.MODE_PRIVATE);
        ObjectOutputStream oos = new ObjectOutputStream(fos);
        oos.writeObject(object);
        oos.close();
        fos.close();
    }

    public static Object readObject(Context context, String filename) throws IOException,
            ClassNotFoundException {
        FileInputStream fis = context.openFileInput(filename);
        ObjectInputStream ois = new ObjectInputStream(fis);
        Object object = ois.readObject();
        return object;
    }

    public static void updateToParse(Entry entry, Context mContext) {
        Boolean status = ConnectionStatus.getNetworkStatus(mContext);

        if (status) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
            query.getInBackground(entry.getParseObjId(), new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (e == null) {

                    } else {
                        // something went wrong
                    }
                }
            });
        }
    }

    public static void saveToParse(final Entry entry, final Context mContext) {
        Boolean status = ConnectionStatus.getNetworkStatus(mContext);

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
                                } else {
                                    Log.d("Entry", "Retrieve after save failed.");
                                }
                            }
                        });
                    }
                }
            });

        } else {
            cachedEntries.add(entry);
            offlineSavedArray.add(entry);
            try {
                EntryManager.writeObject(mContext, cache_file, cachedEntries);
                EntryManager.writeObject(mContext, offline_save_filie, offlineSavedArray);
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }

    public static void updateCacheIdData(ParseObject entry, Context mContext) {
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

    public static void syncWithParse() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

}
