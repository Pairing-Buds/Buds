package com.pairing.buds.common.response;

import org.springframework.stereotype.Component;

@Component
public class Common {

    public static String toString(StatusCode code, Message msg) {
        return code.name() + "_" + msg.getText();
    }

}
