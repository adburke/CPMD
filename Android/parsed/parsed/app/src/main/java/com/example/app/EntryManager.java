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

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

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

    // Singleton Creation
    private static EntryManager m_instance;
    public static List<Entry> cachedEntries;

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
                        // object will be your game score
                    } else {
                        // something went wrong
                    }
                }
            });
        }
    }

}
