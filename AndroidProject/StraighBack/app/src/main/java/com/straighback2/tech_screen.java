package com.straighback2;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.jjoe64.graphview.GraphView;
import com.jjoe64.graphview.GraphViewSeries;
import com.jjoe64.graphview.LineGraphView;

import java.net.SocketException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Handler;


/**
 * Created by filipe on 27-11-2014.
 */



public class tech_screen extends Activity {
    public Receiver receiver;
    private process_data procData ;


    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tech_screen);

        procData = new process_data();
        receiver = new Receiver ( procData );

        try {
            receiver.start();
            //Receiver.start();
        }
        catch (SocketException se) {
            System.out.println("Problem opening socket");
            //NEED TO CHANGE THIS to exit gracefully

        }
        ActionStartsHere();
    }





    public void ActionStartsHere()
    {
        againStartGPSAndSendFile();
    }

    public void againStartGPSAndSendFile()
    {
        new CountDownTimer(60000,100)
        {
            @Override
            public void onTick(long millisUntilFinished)
            {
                // Display Data by Every Ten Second
                //
                plot_chart(200);
            }
            @Override
            public void onFinish()
            {

                plot_chart(0);
            }

        }.start();
    }



    private void plot_chart(int size_plot){

        GraphView.GraphViewData[] data2;
        data2 = procData.generate_graphviredata_acc_1(size_plot);
        plot_chart2(data2, (LinearLayout) findViewById(R.id.ACC), "ACC");

        GraphView.GraphViewData[] data4 = procData.generate_graphviredata_acc_vel_1(size_plot);
        plot_chart2(data4, (LinearLayout) findViewById(R.id.VEL),"VELOCITY");

        GraphView.GraphViewData[] data5 = procData.generate_graphviredata_acc_pos_1(size_plot);
        plot_chart2(data5, (LinearLayout) findViewById(R.id.POS),"POSITION");

        GraphView.GraphViewData[] data3 = procData.generate_graphviredata_post_1(size_plot);
        plot_chart2(data3, (LinearLayout) findViewById(R.id.POSTURE),"POSTURE");
    }

    private void plot_chart2(GraphView.GraphViewData[] data, LinearLayout view, String LABEL){
        System.out.println ("Update chart"+ view.toString());
        //view.removeAllViews();
        int a = view.getChildCount();
        if (a==0) {
            GraphViewSeries seriesSeno = new GraphViewSeries(data);
            LineGraphView graph = new LineGraphView(this, LABEL);
            graph.addSeries(seriesSeno);
            graph.getGraphViewStyle().setGridColor(Color.GRAY);
            graph.getGraphViewStyle().setVerticalLabelsColor(Color.BLACK);
            graph.getGraphViewStyle().setHorizontalLabelsColor(Color.BLACK);
            graph.getGraphViewStyle().setTextSize(20);
            graph.setScrollable(true);
            graph.scrollToEnd();
            graph.setScalable(true);
            view.addView(graph);
            graph.setViewPort(2, 200);
            return;
        }


        LineGraphView graph = (LineGraphView) view.getChildAt(0);
        graph.removeSeries(0);
        GraphViewSeries seriesplot = new GraphViewSeries(data);
        graph.addSeries(seriesplot);
        graph.setViewPort(2, 200);
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



       // graph.setViewPort(2, 100);
        //graph.setManualYAxisBounds()
   //     graph.setScrollable(true);
   //     graph.scrollToEnd();
        // optional - activate scaling / zooming
   //      graph.setScalable(true);
        //graph.getGraphViewStyle().
        //LinearLayout viewACC = (LinearLayout) findViewById(R.id.ACC);
        //view.removeAllViews();
    //    view.addView(graph);

    }
}
