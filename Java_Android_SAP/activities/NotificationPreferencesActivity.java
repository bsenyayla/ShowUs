package com.san.sniper.activities;

import android.annotation.SuppressLint;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import com.san.sniper.R;
import com.san.sniper.registerpushtoken.PushTokenManager;
import com.san.sniper.requestpojos.UpdateNotificationPreferencesRequest;
import com.san.sniper.responsepojos.notification.NotificationPreferencesResponse;
import com.san.sniper.responsepojos.notification.SinglePreferenceResponse;
import com.san.sniper.service.NotificationService;
import com.san.sniper.singletons.SniperUser;
import com.google.android.material.switchmaterial.SwitchMaterial;

import java.util.ArrayList;
import java.util.concurrent.Executors;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint("NonConstantResourceId")
public class NotificationPreferencesActivity extends BaseActivity {

    @BindView(R.id.switch_notify_option_activity)
    SwitchMaterial swNotificationActivityPreference;

    @BindView(R.id.switch_notify_option_lead)
    SwitchMaterial swNotificationLeadPreference;

    @BindView(R.id.switch_notify_option_opportunity)
    SwitchMaterial swNotificationOpportunityPreference;

    @BindView(R.id.switch_notify_option_customer)
    SwitchMaterial swNotificationCustomerPreference;

    @BindView(R.id.switch_notify_option_equipment)
    SwitchMaterial swNotificationEquipmentPreference;

    @BindView(R.id.switch_notify_option_news)
    SwitchMaterial swNotificationNewsPreference;

    @BindView(R.id.switch_notify_option_detail)
    SwitchMaterial swNotificationDetailPreference;

    /*@BindView(R.id.switch_notify_option_link)
    SwitchMaterial swNotificationLinkPreference;*/

    @BindView(R.id.text_fcm_token)
    TextView tvFcmToken;

    UpdateNotificationPreferencesRequest updateNotificationPreferencesRequest;
    NotificationPreferencesResponse notificationPreferencesResponse;
    NotificationService notificationService;
    PushTokenManager pushTokenManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notification_preferences);
        ButterKnife.bind(this);
        notificationService = new NotificationService();
        pushTokenManager = new PushTokenManager(this);
        updateNotificationPreferencesRequest = new UpdateNotificationPreferencesRequest();
        setupToolbar();
        getNotificationPreferences();
    }

    private void setupToolbar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.notification_preferences_title);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
        }
        return super.onOptionsItemSelected(item);
    }

    private void getNotificationPreferences() {
        showProgressDialog();
        notificationService.getNotificationPreferences((result,t)-> {
            if(result != null && result.getPermissions() != null) {
                notificationPreferencesResponse = result;
                //prepare update notification preferences dto
                updateNotificationPreferencesRequest.setUserName(notificationPreferencesResponse.getUserName());
                updateNotificationPreferencesRequest.setPermissions(new ArrayList<>());
                for (SinglePreferenceResponse preference: notificationPreferencesResponse.getPermissions()) {
                    updateNotificationPreferencesRequest.getPermissions().add(preference);
                }
            } else {
                notificationPreferencesResponse = new NotificationPreferencesResponse();
                notificationPreferencesResponse.setPermissions(new ArrayList<>());

                SinglePreferenceResponse activity = new SinglePreferenceResponse("ACTIVITY", false);
                SinglePreferenceResponse lead = new SinglePreferenceResponse("LEAD", false);
                SinglePreferenceResponse equipment = new SinglePreferenceResponse("EQUIPMENT", false);
                SinglePreferenceResponse workOrder = new SinglePreferenceResponse("WORKORDER", false);
                SinglePreferenceResponse link = new SinglePreferenceResponse("LINK", false);
                SinglePreferenceResponse opportunity = new SinglePreferenceResponse("OPPORTUNITY", false);
                SinglePreferenceResponse customer = new SinglePreferenceResponse("CUSTOMER", false);
                SinglePreferenceResponse news = new SinglePreferenceResponse("NEWS", false);

                notificationPreferencesResponse.getPermissions().add(activity);
                notificationPreferencesResponse.getPermissions().add(lead);
                notificationPreferencesResponse.getPermissions().add(equipment);
                notificationPreferencesResponse.getPermissions().add(workOrder);
                notificationPreferencesResponse.getPermissions().add(link);
                notificationPreferencesResponse.getPermissions().add(opportunity);
                notificationPreferencesResponse.getPermissions().add(customer);
                notificationPreferencesResponse.getPermissions().add(news);
                notificationPreferencesResponse.setUserName(SniperUser.getInstance().username);

                //prepare update notification preferences dto
                updateNotificationPreferencesRequest.setUserName(notificationPreferencesResponse.getUserName());
                updateNotificationPreferencesRequest.setPermissions(new ArrayList<>());
                for (SinglePreferenceResponse preference: notificationPreferencesResponse.getPermissions()) {
                    updateNotificationPreferencesRequest.getPermissions().add(preference);
                }
            }

            //setup switches & listeners
            fillNotificationPreferences();
            initPreferenceListeners();
            hideProgressDialog();
            prepareFcmToken();
        });
    }

    private void prepareFcmToken() {
        pushTokenManager.getCurrentTokenAsync().addOnSuccessListener(Executors.newSingleThreadExecutor(), instanceIdResult -> {
            runOnUiThread(() -> tvFcmToken.setText(instanceIdResult.getToken()));
        });

        tvFcmToken.setOnClickListener(v -> {
            ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clip = ClipData.newPlainText("FCM Token", tvFcmToken.getText());
            clipboard.setPrimaryClip(clip);
            Toast.makeText(this, R.string.notification_preferences_fcm_token_copied, Toast.LENGTH_SHORT).show();
        });
    }

    private void fillNotificationPreferences() {
        for (SinglePreferenceResponse preference: notificationPreferencesResponse.getPermissions()) {
            switch (preference.getPermissionName()) {
                case "ACTIVITY":
                    swNotificationActivityPreference.setChecked(preference.isAllowed());
                    break;
                case "LEAD":
                    swNotificationLeadPreference.setChecked(preference.isAllowed());
                    break;
                case "EQUIPMENT":
                    swNotificationEquipmentPreference.setChecked(preference.isAllowed());
                    break;
                case "WORKORDER":
                    swNotificationDetailPreference.setChecked(preference.isAllowed());
                    break;
                case "LINK":
                    break;
                case "OPPORTUNITY":
                    swNotificationOpportunityPreference.setChecked(preference.isAllowed());
                    break;
                case "CUSTOMER":
                    swNotificationCustomerPreference.setChecked(preference.isAllowed());
                    break;
                case "NEWS":
                    swNotificationNewsPreference.setChecked(preference.isAllowed());
                    break;
            }
        }

        //swNotificationLinkPreference.setChecked(notificationPreferencesResponse.isLinkNotification());
    }

    private void initPreferenceListeners() {
        if(updateNotificationPreferencesRequest.getPermissions() == null) {
            getNotificationPreferences();
            return;
        }

        swNotificationActivityPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("ACTIVITY")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationLeadPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("LEAD")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationOpportunityPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("OPPORTUNITY")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationCustomerPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("CUSTOMER")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationEquipmentPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("EQUIPMENT")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationNewsPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("NEWS")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        swNotificationDetailPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            for (SinglePreferenceResponse preference: updateNotificationPreferencesRequest.getPermissions()) {
                if(preference.getPermissionName().equals("WORKORDER")) {
                    preference.setAllowed(isChecked);
                }
            }
            updateNotificationPreferences();
        });

        /*swNotificationLinkPreference.setOnCheckedChangeListener((buttonView, isChecked) -> {
            updateNotificationPreferencesRequest.setLinkNotification(isChecked);
            updateNotificationPreferences();
        });*/
    }

    private void updateNotificationPreferences() {
        notificationService.updateNotificationPreferences(updateNotificationPreferencesRequest, (result,t)-> {});
    }
}
