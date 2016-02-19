package com.straighback2;

import android.util.Log;

import com.jjoe64.graphview.GraphView;

import java.security.KeyStore;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Created by filipe on 26-11-2014.
 */
public class process_data {
    public CopyOnWriteArrayList<ArrayList<Float>> ACC = new CopyOnWriteArrayList<ArrayList<Float>>();
    public CopyOnWriteArrayList<ArrayList<Float>> ACC_DYN = new CopyOnWriteArrayList<ArrayList<Float>>();
    private CopyOnWriteArrayList<ArrayList<Float>> VELOCITY = new CopyOnWriteArrayList<ArrayList<Float>>();
    private float[] Gravity =  {0F , 0F , 0F};
    public CopyOnWriteArrayList<ArrayList<Float>> POS = new CopyOnWriteArrayList<ArrayList<Float>>();
    //If Posture is below zero means that it is BAD.
    public CopyOnWriteArrayList<ArrayList<Float>> POSTURE = new CopyOnWriteArrayList<ArrayList<Float>>();
    public float THRESHOLD[] = {100F, 5F, 100F};
    public float[] CALIBRATED_POSITION = {0F , 0F , 0F};
    private int window_estimation_gravity=40;
    private float SAMPLE_FREQ=50F;
    private float  MEMORY_LOSS_INTEGRATION = 0.9F;

    public void set_parameters (float SAMPLE_freq_set, float MEMORY_LOSS_INTEGRATION_set, int window_estimation_gravity_set, float THRESHOLD0_set,float THRESHOLD1_set,float THRESHOLD2_set){
        THRESHOLD[0]=THRESHOLD0_set;
        THRESHOLD[1]=THRESHOLD1_set;
        THRESHOLD[2]=THRESHOLD2_set;
        window_estimation_gravity=window_estimation_gravity_set;
        SAMPLE_FREQ=SAMPLE_freq_set;
        MEMORY_LOSS_INTEGRATION=MEMORY_LOSS_INTEGRATION_set;
    }

    public void onCreate (){
    }

    public float  get_sampling_freq (){
    return SAMPLE_FREQ;
}

    public void calibrate (){
        if (POS.size()==0) return;
        CALIBRATED_POSITION[0]=POS.get(POS.size()-1).get(0);
        CALIBRATED_POSITION[1]=POS.get(POS.size()-1).get(1);
        CALIBRATED_POSITION[2]=POS.get(POS.size()-1).get(2);
    }
// <summary>
// Check if there was any bad positioning.
// </summary>
// <returns></returns>
    public boolean detect_bad_posture (int search_into_past){

        int window;
        if (search_into_past>POSTURE.size()) window=POSTURE.size(); else window = search_into_past;
        for (int x=POSTURE.size()-window; x<POSTURE.size(); x++){
            for (int d=0;d<3;d++){
                if (POSTURE.get(x).get(d) < 0F) return true;
            }
            //System.out.println("Posture:"+Float.toString(POSTURE.get(x).get(1)));
        }
        return false;
    }

    public boolean update_data() {
        if (ACC.size() == 0) return false;
        if (ACC.size() < window_estimation_gravity) return false;
        if (ACC.size() == VELOCITY.size()) return false;
            //System.out.println("Need to update");//    "need to update it"'
            //for each new point
            for (int x = VELOCITY.size(); x < ACC.size(); x++) {
                if (x < window_estimation_gravity) continue;
                //Calculate the Gravity at such point
                {   for (int k = x - window_estimation_gravity; k < x; k++) {
                    Gravity[0] += ACC.get(k).get(0);
                    Gravity[1] += ACC.get(k).get(1);
                    Gravity[2] += ACC.get(k).get(2);
                    }
                    Gravity[0] = Gravity[0] / (window_estimation_gravity + 1);
                    Gravity[1] = Gravity[1] / (window_estimation_gravity + 1);
                    Gravity[2] = Gravity[2] / (window_estimation_gravity + 1);
                }
                ArrayList<Float> new_acc_dyn = new ArrayList<Float>();
                new_acc_dyn.add(ACC.get(x).get(0)-Gravity[0]);
                new_acc_dyn.add(ACC.get(x).get(1)-Gravity[1]);
                new_acc_dyn.add(ACC.get(x).get(2)-Gravity[2]);
                ACC_DYN.add(new_acc_dyn);


                ArrayList<Float> new_vel = new ArrayList<Float>();
                ArrayList<Float> last_vel;
                if (VELOCITY.size() > 0) last_vel = VELOCITY.get(VELOCITY.size()-1);
                else {
                    last_vel = new ArrayList<Float>();
                    last_vel.add((float)0);last_vel.add((float)0);last_vel.add((float)0);
                }
                new_vel.add(new_acc_dyn.get(0)*(1F/SAMPLE_FREQ) + last_vel.get(0)*MEMORY_LOSS_INTEGRATION);
                new_vel.add(new_acc_dyn.get(1)*(1F/SAMPLE_FREQ) + last_vel.get(1)*MEMORY_LOSS_INTEGRATION);
                new_vel.add(new_acc_dyn.get(2)*(1F/SAMPLE_FREQ) + last_vel.get(2)*MEMORY_LOSS_INTEGRATION);
                VELOCITY.add(new_vel);

                ArrayList<Float> new_pos = new ArrayList<Float>();
                ArrayList<Float> last_pos;
                if (POS.size() > 0) last_pos = POS.get(POS.size()-1);
                else {
                    last_pos = new ArrayList<Float>();
                    last_pos.add((float)0);last_pos.add((float)0);last_pos.add((float)0);
                }

                new_pos.add(last_vel.get(0)*(1F/SAMPLE_FREQ) + last_pos.get(0));
                new_pos.add(last_vel.get(1)*(1F/SAMPLE_FREQ) + last_pos.get(1));
                new_pos.add(last_vel.get(2)*(1F/SAMPLE_FREQ) + last_pos.get(2));
                POS.add(new_pos);


                //POSTURE
                ArrayList<Float> posture = new ArrayList<Float>();
                float post1=THRESHOLD[0]-Math.abs(Math.abs(CALIBRATED_POSITION[0])-Math.abs(new_pos.get(0)));
                float post2=THRESHOLD[1]-Math.abs(Math.abs(CALIBRATED_POSITION[1])-Math.abs(new_pos.get(1)));
                float post3=THRESHOLD[2]-Math.abs(Math.abs(CALIBRATED_POSITION[2])-Math.abs(new_pos.get(2)));

               /* if (post1<0)
                    post1=1;
                else
                    post1=0;
                if (post2<0)
                    post2=1;
                else
                    post2=0;
                if (post3<0)
                    post3=1;
                else
                    post3=0;
*/
                posture.add(post1);
                posture.add(post2);
                posture.add(post3);
                POSTURE.add(posture);
        }

        return true;
    }

    public GraphView.GraphViewData[] generate_graphviredata_acc_1 (int size) {
        return generate_graphviewData(ACC, size);
    }
    public GraphView.GraphViewData[] generate_graphviredata_acc_dyn_1 (int size) {
        return generate_graphviewData(ACC_DYN, size);
    }
    public GraphView.GraphViewData[] generate_graphviredata_acc_vel_1 (int size) {
        return generate_graphviewData(VELOCITY, size);
    }
    public GraphView.GraphViewData[] generate_graphviredata_acc_pos_1 (int size) {
        return generate_graphviewData(POS, size);
    }

    public GraphView.GraphViewData[] generate_graphviredata_post_1 (int size) {
        return generate_graphviewData(POSTURE, size);
    }

    public GraphView.GraphViewData[] generate_graphviredata_posture (int axis,int size) {
        return generate_graphviewData2(POSTURE, size, axis);
    }

    public GraphView.GraphViewData[] generate_graphviewData (CopyOnWriteArrayList<ArrayList<Float>>  data, int size_plot) {
        /// it returns one graphs view data
        update_data();
        int size = data.size();
        if (size_plot>=size) size_plot = size;
        if (size_plot == 0) size_plot = size;

        GraphView.GraphViewData[] data2 = new GraphView.GraphViewData[size_plot];
        //Iterator<ArrayList<Float>> iterator = receiver.ACC.iterator();
        //for (int x = 0; x < 3; x++) {
        for (int k = 0; k < size_plot; k++) {
            data2[k]=new GraphView.GraphViewData(k+size-size_plot, data.get(k+size-size_plot).get(1));
            //System.out.println ("49407 "+receiver.ACC.get(k).get(1));
        }
        //}
        return data2;
    }


    public GraphView.GraphViewData[] generate_graphviewData2 (CopyOnWriteArrayList<ArrayList<Float>>  data, int size_plot, int axis) {
        /// it returns one graphs view data
        update_data();
        int size = data.size();
        if (size_plot>=size) size_plot = size;
        if (size_plot == 0) size_plot = size;

        GraphView.GraphViewData[] data2 = new GraphView.GraphViewData[size_plot];
        //Iterator<ArrayList<Float>> iterator = receiver.ACC.iterator();
        //for (int x = 0; x < 3; x++) {
        for (int k = 0; k < size_plot; k++) {
            data2[k]=new GraphView.GraphViewData(k+size-size_plot, data.get(k+size-size_plot).get(axis));
            //System.out.println ("49407 "+receiver.ACC.get(k).get(1));
        }
        //}
        return data2;
    }

}