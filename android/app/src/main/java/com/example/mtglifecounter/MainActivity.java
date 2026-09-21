package com.example.mtglifecounter;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

public class MainActivity extends Activity {
    private static final String LOCAL_URL = "http://127.0.0.1:8080/";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        startService(new Intent(this, LocalWebService.class));
        startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(LOCAL_URL)));
        finish();
    }
}
