/*
 * Project:		parsed
 *
 * Package:		app
 *
 * Author:		aaronburke
 *
 * Date:		 	4 23, 2014
 */

package com.example.app;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Created by aaronburke on 4/23/14.
 */
public class ConnectionStatus {
    public static Boolean getNetworkStatus(Context context) {
        ConnectivityManager cm = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
        // Get network info object
        NetworkInfo currentNet = cm.getActiveNetworkInfo();
        Boolean status = false;
        // Check the network info object for connection
        if(currentNet != null) {
            if(currentNet.isConnectedOrConnecting()) {
                status = true;
            }
        }
        return status;
    }

    public static String getNetworkStatusType(Context context) {
        ConnectivityManager cm = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
        // Get network info object
        NetworkInfo currentNet = cm.getActiveNetworkInfo();
        String connType = null;
        if(currentNet != null) {
            if (currentNet.getType() == ConnectivityManager.TYPE_WIFI) {
                connType = "Wifi enabled";
            } else if (currentNet.getType() == ConnectivityManager.TYPE_MOBILE) {
                connType = "Mobile data enabled";
            }
        }
        return connType;
    }
}
