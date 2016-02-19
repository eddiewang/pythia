package com.straighback2;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Vibrator;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import java.net.SocketException;
import android.content.Intent;

import com.jjoe64.graphview.GraphView;
import com.jjoe64.graphview.GraphViewSeries;
import com.jjoe64.graphview.GraphViewStyle;
import com.jjoe64.graphview.LineGraphView;


public class MainActivity extends Activity {

    private process_data procData;
    Receiver receiver;

    TextView text;
    @Override

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        text = (TextView)findViewById(R.id.text);
        text.setText("Sit straight and press icon to define correct position.");

        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ipAddress = wifiInfo.getIpAddress();

        procData = new process_data();
        receiver = new Receiver(procData);
        timer_action();
        //TODO: add a new timer for half an hour to remember the person to stand up!

        receiver.textbox=(TextView)findViewById(R.id.text);

        try {
            receiver.start();

        }

        catch (SocketException se){
            System.out.println ("Problem opening socket");
            //NEED TO CHANGE THIS to exit gracefully
        }

        /* to be eliminated */
        String ip = String.format("%d.%d.%d.%d", (ipAddress & 0xff), (ipAddress >> 8 & 0xff), (ipAddress >> 16 & 0xff), (ipAddress >> 24 & 0xff));
        text.append("\nTo be removed after SDK available: Server IP "+ip+":"+receiver.receiverPort);
        text.append("\nConfig save/load not implemented.");
        text.append("\nReturn from other menus and restart server not implemented");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            Intent nextScreen = new Intent(getApplicationContext(), configuration_screen.class);
            startActivity(nextScreen);
            return true;
        }
        if (id == R.id.action_two) {
            System.exit(0);
            return true;
        }
        if (id == R.id.action_three) {
            System.out.println ("Tech screen button");
            //because it is seems to be too complex to send the server to another instance, I will close the server and open again on the next Activity
            receiver.close();
            Intent nextScreen2 = new Intent(getApplicationContext(), tech_screen.class);
            startActivity(nextScreen2);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
    public void onMyButtonClick(View view) {
        System.out.println ("Button1"+" was pressed!");
        Toast.makeText(this, "Button clicked!", Toast.LENGTH_LONG);
    }

    public void CalibratePositionButtonClick(View view) {
        System.out.println("Button1" + " was pressed!");
        procData.calibrate();
        ImageButton a =  (ImageButton) findViewById(R.id.CalibratePositionButton);
        a.setImageResource(R.drawable.goodposture);
        a.setBackgroundColor(0xFF83FF87);
        //to change to bed posture


    }


    public void timer_action()
    {
        final int miliseconds=500;

        new CountDownTimer(100000, miliseconds){
            ImageButton a =  (ImageButton) findViewById(R.id.CalibratePositionButton);
            boolean bad_posture;
            @Override
            public void onTick(long millisUntilFinished)
            {
                int size_plot=1000;
                //GraphView.GraphViewData[] data1 = procData.generate_graphviredata_posture(0, size_plot);
                GraphView.GraphViewData[] data2 = procData.generate_graphviredata_posture(1, size_plot);
                //GraphView.GraphViewData[] data3 = procData.generate_graphviredata_posture(2, size_plot);
                //plot_chart3(data1, data2, data3, (LinearLayout) findViewById(R.id.plot), "");
                plot_chart1(data2,(LinearLayout) findViewById(R.id.plot), "");

                if (procData.detect_bad_posture((int)Math.round(1000/procData.get_sampling_freq()))){
                    if (bad_posture) return;
                    a.setImageResource(R.drawable.badposture);
                    a.setBackgroundColor(0xFFFF5488);
                    Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
                    v.vibrate(300);

                    bad_posture = true;
                    return;
                }
                else{
                    if (!bad_posture) return;
                    a.setImageResource(R.drawable.goodposture);
                    a.setBackgroundColor(0xFF83FF87);
                    bad_posture = false;
                }

            }

            @Override
            public void onFinish()
            {

                //plot_chart(0);
            }

        }.start();
    }


    private void plot_chart3(GraphView.GraphViewData[] data,GraphView.GraphViewData[] data2,GraphView.GraphViewData[] data3, LinearLayout view, String LABEL){
        //System.out.println ("Update chart"+ view.toString());
        //view.removeAllViews();
        int a = view.getChildCount();
        if (a==0) {
            GraphViewSeries seriesSeno = new GraphViewSeries(data);
            LineGraphView graph = new LineGraphView(this, LABEL);
            graph.addSeries(seriesSeno);
            GraphViewSeries seriesSeno2 = new GraphViewSeries(data2);
            graph.addSeries(seriesSeno2);
            GraphViewSeries seriesSeno3 = new GraphViewSeries(data3);
            graph.addSeries(seriesSeno3);
            graph.getGraphViewStyle().setGridColor(Color.GRAY);
            graph.getGraphViewStyle().setVerticalLabelsColor(Color.BLACK);
            graph.getGraphViewStyle().setHorizontalLabelsColor(Color.BLACK);
            graph.getGraphViewStyle().setTextSize(20);
            graph.setShowLegend(false);

            graph.setShowHorizontalLabels(false);
           // graph.setShowVerticalLabels(false);
            graph.setScrollable(true);

            graph.scrollToEnd();
            graph.setScalable(true);
            view.addView(graph);
            graph.setViewPort(2, 200);
            return;
        }

        LineGraphView graph = (LineGraphView) view.getChildAt(0);
        //graph.removeSeries(0);
        graph.removeAllSeries();
        GraphViewSeries seriesplot = new GraphViewSeries ("d1",new GraphViewSeries.GraphViewSeriesStyle(Color.rgb(200, 50, 00), 3),data );
        GraphViewSeries seriesplot2 = new GraphViewSeries("d2",new GraphViewSeries.GraphViewSeriesStyle(Color.rgb(90, 200, 00), 3),data2);
        GraphViewSeries seriesplot3 = new GraphViewSeries("d3",new GraphViewSeries.GraphViewSeriesStyle(Color.rgb(0, 50, 200), 3),data3);
        graph.addSeries(seriesplot);
        graph.addSeries(seriesplot2);
        graph.addSeries(seriesplot3);

        graph.setViewPort(2, 1000);
        graph.setScalable(true);
        graph.scrollToEnd();

        //  View b = view.getChildAt(2);
        //  GraphViewSeries seriesSeno = new GraphViewSeries(data);
        //  LineGraphView graph = new LineGraphView(this, LABEL);
        //  graph.addSeries(seriesSeno);
        ///  graph.getGraphViewStyle().setGridColor(Color.GRAY);
        //  graph.getGraphViewStyle().setVerticalLabelsColor(Color.BLACK);
        //  graph.getGraphViewStyle().setHorizontalLabelsColor(Color.BLACK);
        // graph.getGraphViewStyle().setTextSize(14);


        //graph.setViewPort(2, 100);
        //graph.setManualYAxisBounds()
        //graph.setScrollable(true);
        //graph.scrollToEnd();
        //optional - activate scaling / zooming
        //graph.setScalable(true);
        //graph.getGraphViewStyle().
        //LinearLayout viewACC = (LinearLayout) findViewById(R.id.ACC);
        //view.removeAllViews();
        //    view.addView(graph);

    }

    private void plot_chart1(GraphView.GraphViewData[]  data, LinearLayout view, String LABEL){
        //System.out.println ("Update chart"+ view.toString());
        //view.removeAllViews();
        int a = view.getChildCount();
        if (a==0) {
            GraphViewSeries seriesSeno = new GraphViewSeries(data);
            LineGraphView graph = new LineGraphView(this, LABEL);
            graph.addSeries(seriesSeno);

            graph.getGraphViewStyle().setGridColor(Color.GRAY);

            graph.getGraphViewStyle().setTextSize(20);
            graph.setShowLegend(false);

            graph.setShowHorizontalLabels(false);
            graph.setShowVerticalLabels(false);
            graph.setScrollable(true);

            graph.scrollToEnd();
            graph.setScalable(true);
            view.addView(graph);
            graph.setViewPort(2, 200);
            return;
        }

        LineGraphView graph = (LineGraphView) view.getChildAt(0);
        //graph.removeSeries(0);
        graph.removeAllSeries();

        GraphViewSeries seriesplot2 = new GraphViewSeries("d2",new GraphViewSeries.GraphViewSeriesStyle(Color.rgb(90, 200, 00), 3),data);


        graph.addSeries(seriesplot2);


        graph.setViewPort(2, 1000);
        graph.setScalable(true);
        graph.scrollToEnd();

        //  View b = view.getChildAt(2);
        //  GraphViewSeries seriesSeno = new GraphViewSeries(data);
        //  LineGraphView graph = new LineGraphView(this, LABEL);
        //  graph.addSeries(seriesSeno);
        ///  graph.getGraphViewStyle().setGridColor(Color.GRAY);
        //  graph.getGraphViewStyle().setVerticalLabelsColor(Color.BLACK);
        //  graph.getGraphViewStyle().setHorizontalLabelsColor(Color.BLACK);
        // graph.getGraphViewStyle().setTextSize(14);


        //graph.setViewPort(2, 100);
        //graph.setManualYAxisBounds()
        //graph.setScrollable(true);
        //graph.scrollToEnd();
        //optional - activate scaling / zooming
        //graph.setScalable(true);
        //graph.getGraphViewStyle().
        //LinearLayout viewACC = (LinearLayout) findViewById(R.id.ACC);
        //view.removeAllViews();
        //    view.addView(graph);

    }
}
