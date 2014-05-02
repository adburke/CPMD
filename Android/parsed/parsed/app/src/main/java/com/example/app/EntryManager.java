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

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

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


}
