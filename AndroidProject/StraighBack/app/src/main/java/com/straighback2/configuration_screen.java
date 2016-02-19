package com.straighback2;
import android.os.Bundle;
import android.app.Activity;
import android.widget.SeekBar;

/**
 * Created by filipe on 26-11-2014.
 */
public class configuration_screen extends Activity{
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.configuration_screen);
        SeekBar seekBar = (SeekBar) findViewById(R.id.seekBar1);

        seekBar.setOnSeekBarChangeListener(
                new SeekBar.OnSeekBarChangeListener() {
                    int progress = 0;
                    @Override
                    public void onProgressChanged(SeekBar seekBar,
                                                  int progresValue, boolean fromUser) {
                        progress = progresValue;
                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {
                        // Do something here,
                        //if you want to do anything at the start of
                        // touching the seekbar
                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {
                        // Display the value in textview
                        System.out.println(progress + "/" + seekBar.getMax());
                        //textView.setText(progress + "/" + seekBar.getMax());
                    }
                });
    }
    }


