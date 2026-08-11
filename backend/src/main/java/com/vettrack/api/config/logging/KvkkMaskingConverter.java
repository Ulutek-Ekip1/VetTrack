package com.vettrack.api.config.logging;

import ch.qos.logback.classic.pattern.ClassicConverter;
import ch.qos.logback.classic.spi.ILoggingEvent;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class KvkkMaskingConverter extends ClassicConverter {

    private static final Pattern PASSWORD_PATTERN = Pattern.compile("(?i)(\"password\"\\s*:\\s*\")[^\"]+(\")|(?i)(password\\s*=\\s*)[^,\\s]+");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("(?i)\\b([a-zA-Z0-9._%+-]{1,2})[a-zA-Z0-9._%+-]*@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})\\b");
    private static final Pattern TCKN_PATTERN = Pattern.compile("\\b([1-9]\\d{2})\\d{5}(\\d{3})\\b");
    private static final Pattern PHONE_PATTERN = Pattern.compile("\\b(?:\\+?90|0)?([5]\\d{2})\\d{4}(\\d{2})\\b");

    @Override
    public String convert(ILoggingEvent event) {
        String message = event.getFormattedMessage();
        if (message == null || message.isEmpty()) {
            return message;
        }

        // Mask passwords
        Matcher passwordMatcher = PASSWORD_PATTERN.matcher(message);
        if (passwordMatcher.find()) {
            message = passwordMatcher.replaceAll("$1***MASKED***$2");
        }

        // Mask emails (e.g. kedi1@gmail.com -> ke***@gmail.com)
        Matcher emailMatcher = EMAIL_PATTERN.matcher(message);
        if (emailMatcher.find()) {
            message = emailMatcher.replaceAll("$1***@$2");
        }

        // Mask TCKN (e.g. 12345678901 -> 123*****901)
        Matcher tcknMatcher = TCKN_PATTERN.matcher(message);
        if (tcknMatcher.find()) {
            message = tcknMatcher.replaceAll("$1*****$2");
        }

        // Mask Phone (e.g. 05551234567 -> 0555****67)
        Matcher phoneMatcher = PHONE_PATTERN.matcher(message);
        if (phoneMatcher.find()) {
            message = phoneMatcher.replaceAll("0$1****$2");
        }

        return message;
    }
}
