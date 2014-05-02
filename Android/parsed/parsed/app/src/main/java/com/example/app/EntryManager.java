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
import android.content.SharedPreferences;
import android.util.Log;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseACL;
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
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

/**
 * Created by aaronburke on 4/15/14.
 */
public class EntryManager {

    private static final String cache_file = "entry_data";
    private static final String offline_save_filie = "offline_save_data";

    // Singleton Creation
    private static EntryManager m_instance;
//    public static List<Entry> cachedEntries = new ArrayList<Entry>();
//
//    public static List<Entry> offlineSavedArray = new ArrayList<Entry>();

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

//    public static void updateToParse(final Entry entry, final Context mContext) {
//        Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//        for (Entry cachedEntry : cachedEntries) {
//            if (cachedEntry.getUUID().equals(entry.getUUID())) {
//                cachedEntry.setName(entry.getName());
//                cachedEntry.setMessage(entry.getMessage());
//                cachedEntry.setNumber(entry.getNumber());
//            }
//        }
//
//
//        if (status) {
//            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
//            query.getInBackground(entry.getParseObjId(), new GetCallback<ParseObject>() {
//                public void done(ParseObject object, ParseException e) {
//                    if (e == null) {
//                        object.put("message", entry.getMessage());
//                        object.put("name", entry.getName());
//                        object.put("number", entry.getNumber());
//                        object.saveInBackground(new SaveCallback() {
//                            public void done(ParseException e) {
//                                if (e == null) {
//                                    setModifiedTime(mContext);
//                                }
//                            }
//                        });
//
//                    }
//                }
//            });
//        } else {
//            for (Entry entryOfflineSaved : offlineSavedArray) {
//                if (entryOfflineSaved.getUUID().equals(entry.getUUID())) {
//                    offlineSavedArray.remove(entryOfflineSaved);
//                }
//            }
//            setModifiedTime(mContext);
//            offlineSavedArray.add(entry);
//            try {
//                EntryManager.writeObject(mContext, offline_save_filie, offlineSavedArray);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//
//        }
//    }
//
//    public static void saveToParse(final Entry entry, final Context mContext) {
//        Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//
//        cachedEntries.add(entry);
//
//        if (status) {
//
//            ParseObject entryToSave = new ParseObject("Entry");
//            entryToSave.put("name", entry.getName());
//            entryToSave.put("message", entry.getMessage());
//            entryToSave.put("number", entry.getNumber());
//            entryToSave.put("UUID", entry.getUUID());
//
//            entryToSave.saveInBackground(new SaveCallback() {
//                public void done(ParseException e) {
//                    if (e == null) {
//                        ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
//                        query.whereEqualTo("UUID", entry.getUUID());
//                        query.getFirstInBackground(new GetCallback<ParseObject>() {
//                            public void done(ParseObject object, ParseException e) {
//                                if (object != null) {
//                                    updateCacheIdData(object, mContext);
//                                    setModifiedTime(mContext);
//                                }
//                            }
//                        });
//                    }
//                }
//            });
//
//        } else {
//            offlineSavedArray.add(entry);
//            try {
//                //EntryManager.writeObject(mContext, cache_file, cachedEntries);
//                EntryManager.writeObject(mContext, offline_save_filie, offlineSavedArray);
//                setModifiedTime(mContext);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//
//        }
//    }
//
//    public static void deleteEntryData(Entry entry, final Context mContext) {
//        for (Entry entryCachedObj : cachedEntries) {
//            if (entry.getUUID().equals(entryCachedObj.getUUID())) {
//                cachedEntries.remove(entryCachedObj);
//            }
//        }
//        try {
//            EntryManager.writeObject(mContext, cache_file,cachedEntries);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//
//        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//        if (status) {
//            ParseQuery<ParseObject> query = ParseQuery.getQuery("Entry");
//            query.whereEqualTo("UUID", entry.getUUID());
//            query.getFirstInBackground(new GetCallback<ParseObject>() {
//                public void done(ParseObject object, ParseException e) {
//                    if (object != null) {
//
//                        if (status) {
//                            object.deleteInBackground();
//                        } else {
//                            object.deleteEventually();
//                        }
//                        setModifiedTime(mContext);
//                    }
//                }
//            });
//        } else {
//            setModifiedTime(mContext);
//        }
//
//
//    }
//
//    public static void updateCacheIdData(ParseObject entry, Context mContext) {
//        for (Entry cachedEntry : cachedEntries) {
//            if (entry.getString("UUID").equals(cachedEntry.getUUID())) {
//                cachedEntry.setParseObjId(entry.getObjectId());
//            }
//        }
//        try {
//            EntryManager.writeObject(mContext, cache_file,cachedEntries);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }
//
//    public static void setModifiedTime(Context mContext) {
//        Date date = new Date();
//        final long epoch = date.getTime();
//
//        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//        if (status) {
//            ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
//            query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
//            query.getFirstInBackground(new GetCallback<ParseObject>() {
//                public void done(ParseObject object, ParseException e) {
//                    if (object != null) {
//                        object.put("updateTime", epoch);
//                        object.saveInBackground();
//                    } else {
//                        ParseObject updateStatusObj = new ParseObject("Status");
//                        updateStatusObj.put("userId", ParseUser.getCurrentUser().getObjectId());
//                        updateStatusObj.put("updateTime", epoch);
//                        updateStatusObj.setACL(new ParseACL(ParseUser.getCurrentUser()));
//                        updateStatusObj.saveInBackground();
//                    }
//                }
//            });
//        }
//        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
//        SharedPreferences.Editor editor = preferences.edit();
//        editor.putLong("updateTime", epoch);
//        editor.commit();
//    }
//
//    // Implemented this method to remove parse saveEventually
//    // Updates parse.com with the correct offline data immediately when network returns
//    // Parse.com saveEventually proved unreliable
//    public static void updateParseWithOfflineData(final Context mContext) {
//        List<ParseObject> parseObjects = new ArrayList<ParseObject>();
//        for (Entry entry : offlineSavedArray) {
//            ParseObject entryParse = new ParseObject("Entry");
//            if (entry.getParseObjId().length() != 0) {
//                entryParse.setObjectId(entry.getParseObjId());
//            }
//            entryParse.put("message", entry.getMessage());
//            entryParse.put("name", entry.getName());
//            entryParse.put("number", entry.getNumber());
//            entryParse.put("UUID", entry.getUUID());
//            parseObjects.add(entryParse);
//        }
//        ParseObject.saveAllInBackground(parseObjects,new SaveCallback() {
//            public void done(ParseException e) {
//                if (e == null) {
//                    offlineSavedArray.clear();
//                    try {
//                        EntryManager.writeObject(mContext, offline_save_filie, offlineSavedArray);
//                    } catch (IOException e1) {
//                        e1.printStackTrace();
//                    }
//                    ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
//                    query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
//                    query.getFirstInBackground(new GetCallback<ParseObject>() {
//                        public void done(ParseObject object, ParseException e) {
//                            SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
//                            long time = preferences.getLong("updateTime", 0);
//                            if (object != null) {
//                                object.put("updateTime", time);
//                                object.saveInBackground();
//                            } else {
//                                ParseObject updateStatusObj = new ParseObject("Status");
//                                updateStatusObj.put("userId", ParseUser.getCurrentUser().getObjectId());
//                                updateStatusObj.put("updateTime", time);
//                                updateStatusObj.setACL(new ParseACL(ParseUser.getCurrentUser()));
//                                updateStatusObj.saveInBackground();
//                            }
//                        }
//                    });
//
//                }
//            }
//        });
//
//
//    }
//
//    public static Boolean isUpdateAvailable(Context mContext) {
//        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
//        long updateTime = preferences.getLong("updateTime", 0);
//
//        if (updateTime != 0) {
//            final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//            if (status) {
//                ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
//                query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
//                try {
//                    ParseObject updateStatus = query.getFirst();
//                    if (updateStatus != null) {
//                        long numFromParse = updateStatus.getLong("updateTime");
//                        Log.i("Stored time = ", String.valueOf(updateTime));
//                        Log.i("Parse time = ", String.valueOf(numFromParse));
//                    }
//                } catch (ParseException e) {
//                    e.printStackTrace();
//                }
//            }
//        }
//        return false;
//    }
//
//    public static void newDataUpdate(Context mContext) {
//        cachedEntries.clear();
//        try {
//            EntryManager.writeObject(mContext, cache_file, cachedEntries);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        updateLocalUpdateTime(mContext);
//    }
//
//    public static void updateLocalUpdateTime(final Context mContext) {
//        final Boolean status = ConnectionStatus.getNetworkStatus(mContext);
//        if (status) {
//            ParseQuery<ParseObject> query = ParseQuery.getQuery("Status");
//            query.whereEqualTo("userId", ParseUser.getCurrentUser().getObjectId());
//            query.getFirstInBackground(new GetCallback<ParseObject>() {
//                public void done(ParseObject object, ParseException e) {
//                    if (object != null) {
//                        long time = object.getLong("updateTime");
//                        Log.i("updateLocalUpdateTime", "Time from Parse = " + String.valueOf(time));
//                        SharedPreferences preferences = mContext.getSharedPreferences("MyPreferences", Context.MODE_PRIVATE);
//                        SharedPreferences.Editor editor = preferences.edit();
//                        editor.putLong("updateTime", time);
//                        editor.commit();
//                    }
//                }
//            });
//        }
//    }
}
