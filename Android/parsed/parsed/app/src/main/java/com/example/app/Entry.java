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

import java.io.Serializable;
import java.util.UUID;

/**
 * Created by aaronburke on 4/15/14.
 */
public class Entry implements Serializable {

    private String name;
    private String message;
    private Number number;
    private String parseObjId;
    private String mUUID;

    public Entry(String name, String message, Number number) {
        this.name = name;
        this.message = message;
        this.number = number;
        this.parseObjId = "";
        this.mUUID = UUID.randomUUID().toString();
    }

    public Entry(String name, String message, Number number, String parseObjectId, String mUUID) {
        this.name = name;
        this.message = message;
        this.number = number;
        this.parseObjId = parseObjectId;
        this.mUUID = mUUID;
    }

    public String getName() {
        return name;
    }
    public String getMessage() {
        return message;
    }
    public Number getNumber() {
        return number;
    }
    public String getUUID() { return mUUID;}

}
