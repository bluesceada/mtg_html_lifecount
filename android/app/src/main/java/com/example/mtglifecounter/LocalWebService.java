package com.example.mtglifecounter;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;

public class LocalWebService extends Service {
    private static final int PORT = 8080;
    private ServerSocket serverSocket;
    private volatile boolean running;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForegroundIfNeeded();
        if (!running) {
            running = true;
            Thread serverThread = new Thread(new Runnable() {
                @Override
                public void run() {
                    serveLoop();
                }
            }, "mtg-local-web-server");
            serverThread.start();
        }
        return START_STICKY;
    }

    private void serveLoop() {
        try {
            serverSocket = new ServerSocket(PORT, 8, java.net.InetAddress.getByName("127.0.0.1"));
            while (running) {
                final Socket client = serverSocket.accept();
                Thread clientThread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        serveClient(client);
                    }
                }, "mtg-http-client");
                clientThread.start();
            }
        } catch (IOException ignored) {
            // The service will be restarted by Android if it is stopped unexpectedly.
        } finally {
            running = false;
        }
    }

    private void serveClient(Socket client) {
        try {
            BufferedReader reader = new BufferedReader(new java.io.InputStreamReader(client.getInputStream()));
            String requestLine = reader.readLine();
            if (requestLine == null || !requestLine.startsWith("GET ")) {
                client.close();
                return;
            }
            String headerLine;
            while ((headerLine = reader.readLine()) != null && headerLine.length() > 0) {
                // Consume request headers.
            }

            InputStream page = getAssets().open("index.html");
            byte[] body = readAll(page);
            OutputStream output = client.getOutputStream();
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(output, "UTF-8"));
            writer.write("HTTP/1.0 200 OK\r\n");
            writer.write("Content-Type: text/html; charset=utf-8\r\n");
            writer.write("Content-Length: " + body.length + "\r\n");
            writer.write("Cache-Control: no-store\r\n");
            writer.write("Connection: close\r\n\r\n");
            writer.flush();
            output.write(body);
            output.flush();
            page.close();
            client.close();
        } catch (IOException ignored) {
            try {
                client.close();
            } catch (IOException ignoredClose) {
                // Nothing else to do for a disconnected browser.
            }
        }
    }

    private byte[] readAll(InputStream input) throws IOException {
        java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int count;
        while ((count = input.read(buffer)) != -1) {
            output.write(buffer, 0, count);
        }
        return output.toByteArray();
    }

    private void startForegroundIfNeeded() {
        Intent launch = new Intent(this, MainActivity.class);
        PendingIntent pending = PendingIntent.getActivity(this, 0, launch, 0);
        Notification.Builder builder = new Notification.Builder(this);
        builder.setContentTitle("MTG Life Counter")
                .setContentText("Local web server: http://127.0.0.1:8080/")
                .setSmallIcon(android.R.drawable.ic_menu_view)
                .setContentIntent(pending)
                .setOngoing(true);
        startForeground(1, builder.build());
    }

    @Override
    public void onDestroy() {
        running = false;
        if (serverSocket != null) {
            try {
                serverSocket.close();
            } catch (IOException ignored) {
                // Server is already shutting down.
            }
        }
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
