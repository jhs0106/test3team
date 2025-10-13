package edu.sm.rtc;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class SignalMessage {
    private String type;
    private String targetSessionId;
    private Object data;
    private String roomId;
    private String senderSessionId;
}//