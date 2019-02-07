import java.awt.Robot;
import java.awt.event.*;
import java.lang.Thread;
import java.text.SimpleDateFormat;
import java.util.Date;

/* MAKE SURE MATLAB CODE FOR 2018 HAS ALREADY BEEN STARTED AND DAQ IS READY FOR ACQUISITION*/

public class SweepAutomater{

	public static final int SWEEP_START					 = 2;
	public static final int SWEEP_STOP					 = 512;
	public static final int SWEEP_INT 					 = 2;

	public static final int SWEEP_TIME_MS 				 = 38000;
	public static final int SWEEP_TIME_TOLERANCE_MS		 = 2000;
	public static final int FPGA_PROGRAM_MS				 = 4000;
	public static final int FPGA_MOD_MS					 = 500;

	public static final int FPGA_RUN_X					 = 550;
	public static final int FPGA_RUN_Y					 = 80;

	public static final int FPGA_MOD_X					 = 426;
	public static final int FPGA_MOD_Y					 = 703;

	public static final int SWEEP_X						 = 1250;
	public static final int SWEEP_Y 					 = 900;

	public static final int NUM_PROG_BARS 				 = 60;
	public static final char PROGRESS 					 = 0x2588;

	public static void main(String[] args){
		try{
			Robot r = new Robot();
			System.out.println("Auto starting in 5 seconds. Please open correct windows");
			Thread.sleep(5000);
			System.out.println("Robot Started at " + (new SimpleDateFormat("HH:mm:ss").format(new Date())));
			long startTime = System.currentTimeMillis();
			System.out.println();

			// do the cycle
			for(int i = SWEEP_START; i <= SWEEP_STOP; i += SWEEP_INT){
				// System.out.println("Running Robot for "+i+"Sweep");
				// int i = 300;

				// Print Progress
				System.out.print(consProgString(i));
				// Thread.sleep(100);

				// modify FPGA
				r.mouseMove(FPGA_MOD_X, FPGA_MOD_Y);
				r.mousePress(MouseEvent.BUTTON1_DOWN_MASK);
				r.mouseRelease(MouseEvent.BUTTON1_DOWN_MASK);
				int int1 = (int) Math.floor((i%1000)/100);
				int int2 = (int) Math.floor((i%100)/10);
				int int3 = i%10;
				r.keyPress(KeyEvent.VK_BACK_SPACE);
				r.keyRelease(KeyEvent.VK_BACK_SPACE);
				r.keyPress(KeyEvent.VK_BACK_SPACE);
				r.keyRelease(KeyEvent.VK_BACK_SPACE);
				r.keyPress(KeyEvent.VK_BACK_SPACE);
				r.keyRelease(KeyEvent.VK_BACK_SPACE);
				r.keyPress(48+int1);
				r.keyRelease(48+int1);
				r.keyPress(48+int2);
				r.keyRelease(48+int2);
				r.keyPress(48+int3);
				r.keyRelease(48+int3);
				Thread.sleep(FPGA_MOD_MS);

				// run FPGA
				r.mouseMove(FPGA_RUN_X, FPGA_RUN_Y);
				r.mousePress(MouseEvent.BUTTON1_DOWN_MASK);
				r.mouseRelease(MouseEvent.BUTTON1_DOWN_MASK);
				Thread.sleep(FPGA_PROGRAM_MS);

				// enter info in sweeper
				r.mouseMove(SWEEP_X, SWEEP_Y);
				r.mousePress(MouseEvent.BUTTON1_DOWN_MASK);
				r.mouseRelease(MouseEvent.BUTTON1_DOWN_MASK);
				r.keyPress(48+int1);
				r.keyRelease(48+int1);
				r.keyPress(48+int2);
				r.keyRelease(48+int2);
				r.keyPress(48+int3);
				r.keyRelease(48+int3);
				r.keyPress(KeyEvent.VK_ENTER);
				r.keyRelease(KeyEvent.VK_ENTER);
				Thread.sleep(SWEEP_TIME_MS+SWEEP_TIME_TOLERANCE_MS);
			}
			System.out.println("\n\nAutomation Complete :)");
			// Enter -1 in the Matlab
			r.mouseMove(SWEEP_X, SWEEP_Y);
			r.mousePress(MouseEvent.BUTTON1_DOWN_MASK);
			r.mouseRelease(MouseEvent.BUTTON1_DOWN_MASK);
			r.keyPress(KeyEvent.VK_MINUS);
			r.keyRelease(KeyEvent.VK_MINUS);
			r.keyPress(KeyEvent.VK_1);
			r.keyRelease(KeyEvent.VK_1);
			r.keyPress(KeyEvent.VK_ENTER);
			r.keyRelease(KeyEvent.VK_ENTER);
			System.out.println("Robot Ended at " + (new SimpleDateFormat("HH:mm:ss").format(new Date())));
			long t = System.currentTimeMillis() - startTime;
			long s = (t / 1000) % 60;
			long m = (t / 60000) % 60;
			long h = (t / 3600000) % 60;
			System.out.println("Elapsed Time of " + (String.format("%02d:%02d:%02d", h, m, s)));

		}catch(Exception e){
			System.out.println("\n\nSomething went wrong with robot");
			System.err.println(e);
		}
	}

	public static String consProgString(int i){
		int total = (SWEEP_STOP - SWEEP_START) / SWEEP_INT + 1;
		int curr = (i - SWEEP_START) / SWEEP_INT + 1;
		float perc = (float) curr/ (float)total;
		float percperbar = (float)1/(float)NUM_PROG_BARS;

		String ret = "\r|";
		for(int j = 1; j <= NUM_PROG_BARS; j++){
			if(j*percperbar <= perc) ret += PROGRESS;
			else ret += "-";
		}
		ret += "| "+Float.toString(perc*100).substring(0, 4)+"% Sweep Progress: " + curr + "/" + total + "        ";
		return ret;
	}
}