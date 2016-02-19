package com.straighback2;

import android.widget.TextView;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Created by filipe on 27-11-2014.
 */
class Receiver {
    public static int capacity = 10;
    public TextView textbox = null;
    public CopyOnWriteArrayList<ArrayList<Float>> ACC;
    private OSCPortIn receiver;
    private OSCListener listener;
    public int receiverPort = 5003;

    public void print_ACC (){

        Iterator iterator = ACC.iterator();
        //check values
        int i=0;
        String s="";
        while (iterator.hasNext()){
            int b=0;
        }
        //textbox.append(String.format("%i",ACC.size()));
    }

    public Receiver(process_data aux){
        ACC=aux.ACC;
    }

    public Receiver(){

        ACC = new CopyOnWriteArrayList<ArrayList<Float>>();
    }

    public void start() throws java.net.SocketException {
        // Pass in whatever port number to listen on

        receiver = new OSCPortIn(receiverPort);
        // We define a message handler to process messages
        // This library calls its message handlers OSCListener
        // since they "listen" for an event to happen and process
        // it once they "hear" one.
        // OSCListener handler1 = new OSCListener() {
        //    public void acceptMessage(java.util.Date time, OSCMessage message) {

        //System.out.println("Handler1 called with address " + message.getAddress());
        // Print out values
        //Object[] values = message.getArguments();
        //System.out.printf("Values: [%s", values[0]);
        //for (int i = 1; i < values.length; i++)
        //    System.out.printf(", %s", values[i]);
        //        System.out.println("I should have read something\n");
        //        textbox.append("Received something\n");
        //    }
        //};
        // I want handler1 to be called on addresses /a and /b and
        // handler2 to be called on /c
        //receiver.addListener("/a", handler1);
        //receiver.addListener("/b", handler1);

        listener = new OSCListener() {
            public void acceptMessage(java.util.Date time, OSCMessage message) {
                message.getArguments();
                //System.out.println("Message received!");
                ArrayList<Float> last_reading = new ArrayList<Float>();
                float[] newreading= new float[3];
                Object a;
                String x;
                for ( int i = 0; i < message.getArguments().size(); i++){
                    //System.out.println(message.getArguments().get(i));
                    a = message.getArguments().get(i);
                    x = message.getArguments().get(i).toString();
                    newreading[i]= Float.parseFloat(x);
                    last_reading.add(Float.parseFloat(x));
                }
                ACC.add(last_reading);

                String s = String.format("acc: %f %f %f", message.getArguments().get(0),message.getArguments().get(1),message.getArguments().get(2));
                //System.out.println(s);
            }
        };
        receiver.addListener("/muse/acc", listener);
        System.out.println("Server is listening on port " + receiverPort + "...");
        receiver.startListening();

    }
    public void close(){
        receiver.stopListening();
        receiver.close();
    }

}