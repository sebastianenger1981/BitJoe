package de.hgnut.Misc;
/*****************************************************************/
import javax.microedition.lcdui.Command;
/*****************************************************************/
public class GuiAction {
	public String MESSAGE;
	public String SOURCE;
	public int STATUS;
	public Command COMMAND;
/*****************************************************************/	
	public GuiAction(String source, String message, int status, Command command){		
		this.SOURCE=source;		
		this.MESSAGE=message;
		this.STATUS=status;
		this.COMMAND=command;
	}
/*****************************************************************/
}