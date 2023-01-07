package com.san.sniper.activities;

import android.app.Application;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.util.DisplayMetrics;

import com.san.sniper.Utility;
import com.san.sniper.inbox.data.InboxMessageResponse;
import com.san.sniper.inbox.data.InboxResponse;
import com.san.sniper.responsepojos.NewsItem;
import com.san.sniper.utility.AppExceptionHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


public class SniperApplication extends Application {
    public static SniperApplication application;

    private boolean isComingFromNewsNotification = false;
    private String newsIdFromNotification;
    private boolean isComingFromEquipmentNotification = false;
    private String serialNoFromNotification;
    private List<NewsItem> globalNewsItems;

    @Override
    public void onCreate() {
        super.onCreate();
        application = this;
        setupCrashHandler();

        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
    }

    private void setupCrashHandler() {
        /*Thread.UncaughtExceptionHandler systemHandler = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler(new AppExceptionHandler( this, systemHandler));*/
    }

    public List<NewsItem> getGlobalNewsItems() {
        return globalNewsItems;
    }

    public void setGlobalNewsItems(List<NewsItem> globalNewsItems) {
        this.globalNewsItems = globalNewsItems;
    }

    public static SniperApplication getApplication() {
        return application;
    }

    public static void setApplication(SniperApplication application) {
        SniperApplication.application = application;
    }

    public boolean isComingFromEquipmentNotification() {
        return isComingFromEquipmentNotification;
    }

    public void setComingFromEquipmentNotification(boolean comingFromEquipmentNotification) {
        isComingFromEquipmentNotification = comingFromEquipmentNotification;
    }

    public String getSerialNoFromNotification() {
        return serialNoFromNotification;
    }

    public void setSerialNoFromNotification(String serialNoFromNotification) {
        this.serialNoFromNotification = serialNoFromNotification;
    }

    public boolean isComingFromNewsNotification() {
        return isComingFromNewsNotification;
    }

    public void setComingFromNewsNotification(boolean comingFromNewsNotification) {
        isComingFromNewsNotification = comingFromNewsNotification;
    }

    public String getNewsIdFromNotification() {
        return newsIdFromNotification;
    }

    public void setNewsIdFromNotification(String newsIdFromNotification) {
        this.newsIdFromNotification = newsIdFromNotification;
    }
}
