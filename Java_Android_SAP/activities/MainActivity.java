package com.san.sniper.activities;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

import com.san.sniper.LogConstants;
import com.san.sniper.SSOWebViewNavigationUseCase;
import com.san.sniper.Section;
import com.san.sniper.Util;
import com.san.sniper.WebContentActivity;
import com.san.sniper.entity.MenuItemEntity;
import com.san.sniper.enums.PushTypes;
import com.san.sniper.enums.ServiceQuotationStatus;
import com.san.sniper.fragments.CatapultFragment;
import com.san.sniper.fragments.CustomerFieldWorkFragment;
import com.san.sniper.fragments.MachineWizardFragment;
import com.san.sniper.fragments.ServiceQuotationApprovalFragment;
import com.san.sniper.inbox.InboxActivity;
import com.san.sniper.inbox.data.InboxMessageResponse;
import com.san.sniper.inbox.data.MessageEventRequest;
import com.san.sniper.push_event.CustomerPushEventHandler;
import com.san.sniper.registerpushtoken.PushTokenManager;
import com.san.sniper.registerpushtoken.RegisterPushTokenUseCase;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.notification.DetailTypePushNotificationResponse;
import com.san.sniper.responsepojos.servicequotation.ServiceQuotationListResponse;
import com.san.sniper.responsepojos.simapproval.SIMApprovals;
import com.san.sniper.service.AuthService;
import com.san.sniper.service.InboxService;
import com.google.android.material.appbar.AppBarLayout;
import com.google.android.material.navigation.NavigationView;

import androidx.annotation.RequiresApi;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.core.view.GravityCompat;
import androidx.core.view.ViewCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.ProcessLifecycleOwner;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.san.sniper.AppConstants;
import com.san.sniper.CityList;
import com.san.sniper.DataKeys;
import com.san.sniper.OnBackPressListener;
import com.san.sniper.R;
import com.san.sniper.SplashActivity;
import com.san.sniper.Utility;
import com.san.sniper.adapters.SIMApprovalsAdapter;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.fragments.CatalogFragment;
import com.san.sniper.fragments.CheckInFragments.CheckInMapFragment;
import com.san.sniper.fragments.CompaintFragment;
import com.san.sniper.fragments.CompetitorSparePartPriceFragment;
import com.san.sniper.fragments.CustomerFragment;
import com.san.sniper.fragments.ExpertiseFragment;
import com.san.sniper.fragments.HasOwnAppBar;
import com.san.sniper.fragments.MachineSearchFragment;
import com.san.sniper.fragments.NewsFragment;
import com.san.sniper.fragments.ProposalFragment;
import com.san.sniper.fragments.ReportFragment;
import com.san.sniper.fragments.RouteFragment;
import com.san.sniper.fragments.ServiceDemandFragment;
import com.san.sniper.fragments.ServiceDocumentApprovalFragment;
import com.san.sniper.fragments.SparePartOrderFragment;
import com.san.sniper.fragments.SparePartStockStatusFragment;
import com.san.sniper.fragments.WebContentFragment;
import com.san.sniper.fragments.WorkshopOperationFragment;
import com.san.sniper.responsepojos.response.CitiesResponse;
import com.san.sniper.service.BaseService;
import com.san.sniper.service.CheckInService;
import com.san.sniper.singletons.DataTransfer;
import com.san.sniper.singletons.SniperUser;
import com.google.firebase.crashlytics.FirebaseCrashlytics;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.concurrent.Executors;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

public class MainActivity extends BaseActivity implements NavigationView.OnNavigationItemSelectedListener, LifecycleObserver {

    public LinkedHashMap<String, Integer> fragidMap = new LinkedHashMap<>();

    Section[] allSections;
    NavigationView navigationView;
    private AppBarLayout mainAppBar;
    boolean appIsBackground = false;
    SharedPreferences preferences;
    AuthService authService;
    ArrayList<MenuItemEntity> menuItems;

    @BindView(R.id.layout_network_view_progress)
    ConstraintLayout networkView;

    RelativeLayout layoutNotificationBubble;
    TextView tvNotificationBadgeCount;

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.bind(this);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        authService = new AuthService(this);

        Intent intent = getIntent();
        if (intent != null && intent.getExtras() != null) {
            prpWebContent(intent);
        }

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        mainAppBar = findViewById(R.id.mainAppBar);
        setSupportActionBar(toolbar);
        navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        navigationView.setItemIconTintList(null);

        View headerView = navigationView.getHeaderView(0);
        Menu modulemenu = navigationView.getMenu();
        SubMenu fioriMenu = modulemenu.findItem(R.id.fiori_group).getSubMenu();

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);

        drawer.addDrawerListener(toggle);
        drawer.addDrawerListener(new DrawerLayout.SimpleDrawerListener() {
            @Override
            public void onDrawerStateChanged(int newState) {
                if (newState == DrawerLayout.STATE_SETTLING && !drawer.isDrawerOpen(GravityCompat.START)) {
                    // Drawer started opening
                    hideKeyboard();
                }
            }
        });
        toggle.syncState();

        allSections = AppConstants.applicationSections;

        TextView firstandlastname = (TextView) headerView.findViewById(R.id.firstandlastname);
        String drawerNameText = String.format("%s %s", SniperUser.getInstance().firstName, SniperUser.getInstance().lastName);
        if (RetrofitBuilder.mBaseUrl.equals(RetrofitBuilder.testUrl)) {
            drawerNameText += " / TEST ENV";
        }
        firstandlastname.setText(drawerNameText);

        ImageView ivNotifications = (ImageView) headerView.findViewById(R.id.image_notification_button);
        ivNotifications.setOnClickListener(v -> {
            PushTokenManager pushTokenManager = new PushTokenManager(this);
            String lastRegisteredPushToken = pushTokenManager.getLastRegisteredPushToken();
            Utility.logUsage(LogConstants.Section.Inbox, LogConstants.Activity.VIEW_INBOX, "username: " + SniperUser.getInstance().username + ", tokenId: " + lastRegisteredPushToken);
            startActivity(InboxActivity.newIntent(this));
        });

        layoutNotificationBubble = (RelativeLayout) headerView.findViewById(R.id.layout_notification_bubble);
        tvNotificationBadgeCount = (TextView) headerView.findViewById(R.id.text_notification_badge_count);

        listenPushNotifications();
        getNotificationLookupData();

        List<String> userSections = SniperUser.getInstance().sectionList;
        menuItems = new ArrayList<>();

        if (userSections == null) {
            userSections = new ArrayList<>();
        }
        for (int i = 0; i < allSections.length; i++) {
            Section section = allSections[i];
            String sectionName = section.getName();
            String title = getTitleForSection(sectionName);
            int id = View.generateViewId();
            MenuItem item;

            if (section.isFiori()) {
                item = fioriMenu.add(R.id.fioriSections, id, i, title);
            } else {
                item = modulemenu.add(R.id.sniperFrags, id, i, title);
            }

            item.setVisible(false);
            fragidMap.put(sectionName, id);
            if (userSections.contains(sectionName)) {
                item.setVisible(true);
                if(sectionName.equals(Section.SNIPER_SURVEY)) {
                    if(SniperUser.getInstance().sniperSurveyUrl == null || SniperUser.getInstance().sniperSurveyUrl.isEmpty()) {
                        item.setVisible(false);
                    }
                }
            }

            setIconForSection(sectionName, item);

            if (sectionName.equals(Section.SERVICE_REQUEST_APPROVAL)) {
                item.setVisible(false);
            }

            if (sectionName.equals(Section.SERVICE_OFFER_APPROVAL)) {
                if (SniperUser.isCanSeeServiceQuotationApprovalSection()) {
                    item.setVisible(true);
                    DataTransfer.getInstance().putData(DataKeys.SERVICE_QUOTATION_MENU_ITEM, item);
                } else {
                    item.setVisible(false);
                }
            }

            menuItems.add(new MenuItemEntity(item, sectionName));
        }

        //Survey
        String survey = getString(R.string.fragSniperSurvey);
        int surveyId = View.generateViewId();
        fragidMap.put("Survey", surveyId);
        SpannableString spanString = new SpannableString(survey);
        spanString.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.carrot)), 0, spanString.length(), 0);
        MenuItem surveyMenuItem = modulemenu.add(R.id.actions, surveyId, 1000, spanString); // fiorisections order is 900

        Drawable iconSurvey = getResources().getDrawable(R.drawable.ic_survey);
        iconSurvey.setColorFilter(getResources().getColor(R.color.carrot), PorterDuff.Mode.SRC_IN);
        surveyMenuItem.setIcon(iconSurvey);

        //Logout
        String title = getString(R.string.logout);
        int id = View.generateViewId();
        fragidMap.put("Logout", id);
        MenuItem item = modulemenu.add(R.id.actions, id, 1001, title); // fiorisections order is 900
        Drawable iconLogOut = getResources().getDrawable(R.drawable.ic_exit_to_app_black_24px);
        iconLogOut.setColorFilter(getResources().getColor(R.color.black), PorterDuff.Mode.SRC_IN);
        item.setIcon(iconLogOut);

        fetchDataFromService();

        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        transaction.replace(R.id.contentMainLayout, new NewsFragment());
        transaction.commit();

        // update firebase user information
        FirebaseCrashlytics.getInstance().setUserId(SniperUser.getInstance().username);

        // register push notification
        RegisterPushTokenUseCase
                .create(this)
                .execute();

        //register lifecycle events
        ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
    }

    private void getNotificationLookupData() {
        PushTokenManager pushTokenManager = new PushTokenManager(this);
        pushTokenManager.getCurrentTokenAsync().addOnSuccessListener(Executors.newSingleThreadExecutor(), instanceIdResult -> {
            runOnUiThread(() -> getNotificationBubbleData(pushTokenManager, instanceIdResult.getToken()));
        });
    }

    private void getNotificationBubbleData(PushTokenManager pushTokenManager, String fcmToken) {
        InboxService inboxService = new InboxService();
        inboxService.getMessages(fcmToken, SniperUser.getInstance().username, SniperUser.getInstance().getUserCountryCode(), (result,t)-> {
            if(result != null) {
                List<InboxMessageResponse> messages = result.getData();
                int unreadMessagesCount = 0;
                if(messages != null && messages.size() > 0) {
                    for(InboxMessageResponse message: messages) {
                        if(!message.isRead()) {
                            unreadMessagesCount++;
                        }
                    }
                }
                if(unreadMessagesCount > 0) {
                    layoutNotificationBubble.setVisibility(View.VISIBLE);
                    tvNotificationBadgeCount.setText(String.valueOf(unreadMessagesCount));
                }
                pushTokenManager.saveNotificationBadgeCount(unreadMessagesCount);
            }
        });
    }

    private void listenPushNotifications() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("PUSH_RECEIVED");
        intentFilter.addAction("PUSH_BADGE_UPDATED");
        LocalBroadcastManager.getInstance(this).registerReceiver(pushReceiver, intentFilter);
    }

    private final BroadcastReceiver pushReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if (action == null) return;
            if (action.equals("PUSH_RECEIVED")) {
                PushTokenManager pushTokenManager = new PushTokenManager(MainActivity.this);
                int currentUnreadPushNotification = pushTokenManager.getNotificationBadgeCount();
                currentUnreadPushNotification += 1;
                pushTokenManager.saveNotificationBadgeCount(currentUnreadPushNotification);

                layoutNotificationBubble.setVisibility(View.VISIBLE);
                tvNotificationBadgeCount.setText(String.valueOf(currentUnreadPushNotification));
            } else if(action.equals("PUSH_BADGE_UPDATED")) {
                PushTokenManager pushTokenManager = new PushTokenManager(MainActivity.this);
                int currentUnreadPushNotification = pushTokenManager.getNotificationBadgeCount();
                if(currentUnreadPushNotification > 0) {
                    layoutNotificationBubble.setVisibility(View.VISIBLE);
                    tvNotificationBadgeCount.setText(String.valueOf(currentUnreadPushNotification));
                } else {
                    layoutNotificationBubble.setVisibility(View.GONE);
                }
            }
        }
    };

    private void prpWebContent(Intent intent) {
        String actionType = intent.getExtras().getString("actionType", "");
        String actionUrl = intent.getExtras().getString("actionUrl", "");
        String messageId = intent.getExtras().getString("MESSAGE_ID");
        String inboxMessageId = intent.getExtras().getString("InboxMessageId");

        String title = intent.getExtras().getString("title", "");
        boolean sso = intent.getExtras().getBoolean("sso", false);

        PushTypes pushEventType = PushTypes.get(actionType);
        if(!actionType.isEmpty() && (messageId != null || inboxMessageId != null)) {
            if(messageId == null) {
                sendPushNotificationClickedEvent(actionType, inboxMessageId, actionUrl);
            } else if(inboxMessageId == null) {
                sendPushNotificationClickedEvent(actionType, messageId, actionUrl);
            }
        }

        if(pushEventType == PushTypes.LINK) {
            Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.LINK_CLICKED, actionUrl);
        } else if(pushEventType == PushTypes.LEAD) {
            Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.LEAD_CLICKED, actionUrl);
        } else if(pushEventType == PushTypes.OPPORTUNITY) {
            Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.OPPORTUNITY_CLICKED, actionUrl);
        }

        if(!actionType.isEmpty() && (messageId != null || inboxMessageId != null)) {
            if(messageId == null) {
                markNotificationAsRead(actionType, inboxMessageId);
            } else if(inboxMessageId == null) {
                markNotificationAsRead(actionType, messageId);
            }
        }

        SSOWebViewNavigationUseCase
                .create(this)
                .execute(pushEventType, actionUrl, title, sso);

        if (isFromPushNotification(intent)) {
            if(pushEventType == PushTypes.ACTIVITY) {
                //Go to ActivityDetail
                String activityId = intent.getExtras().getString("objectId", null);
                if(activityId != null) {
                    Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.ACTIVITY_CLICKED, "activityId: " + activityId);
                    Intent i = new Intent(this, CheckInManagementActivity.class);
                    i.putExtra(CheckInManagementActivity.ACTIVITY_OBJECT_ID, activityId);
                    i.putExtra(CheckInManagementActivity.TO_VIEW_TAG,CheckInManagementActivity.FRAGMENT_ACTIVITY_DETAIL);
                    startActivity(i);
                }
            } else if(pushEventType == PushTypes.CUSTOMER) {
                //Go to CustomerDetail & Start Loading..
                String customerNo = intent.getExtras().getString("customerNo", null);
                if(customerNo != null) {
                    Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.CUSTOMER_CLICKED, "customerNo: " + customerNo);
                    networkView.setVisibility(View.VISIBLE);
                    CustomerPushEventHandler.create(this).execute(customerNo, (result, t) -> {
                        if(result != null) {
                            networkView.setVisibility(View.GONE);
                            Intent customerDetailIntent = new Intent(this, CustomerDetailActivity.class);
                            customerDetailIntent.putExtra("customerobj", result);
                            startActivity(customerDetailIntent);
                        } else {
                            Toast.makeText(this, "Customer Not Found.", Toast.LENGTH_SHORT).show();
                            networkView.setVisibility(View.GONE);
                        }
                    });
                }
            } else if(pushEventType == PushTypes.DETAIL) {
                //Go to Details & Start Loading..
                try {
                    String detailData = intent.getExtras().getString("details", null);
                    if(detailData != null) {
                        Gson gson  = new Gson();
                        ArrayList<DetailTypePushNotificationResponse> mappedDetailsTypeNotificationData = gson.fromJson(detailData, new TypeToken<ArrayList<DetailTypePushNotificationResponse>>(){}.getType());
                        if(mappedDetailsTypeNotificationData != null && mappedDetailsTypeNotificationData.size() > 0) {
                           //Open with Details Activity
                            Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.DETAIL_CLICKED, "detailData: " + detailData);
                            Intent detailListActivity = new Intent(this, DetailListActivity.class);
                            detailListActivity.putExtra("detailitems", mappedDetailsTypeNotificationData);
                            startActivity(detailListActivity);
                        }
                    }
                } catch (Exception ex) {
                    System.out.println(ex.toString());
                }
            } else if(pushEventType == PushTypes.EQUIPMENT) {
                //Go to Customer -> EQUIPMENT Detail
                String customerNo = intent.getExtras().getString("customerNo", null);
                String serialNo = intent.getExtras().getString("serialNo", null);
                if(customerNo != null && serialNo != null) {
                    Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.EQUIPMENT_CLICKED, "serialNo: " + serialNo + ", customerNo: " + customerNo);
                    networkView.setVisibility(View.VISIBLE);
                    CustomerPushEventHandler.create(this).execute(customerNo, (result, t) -> {
                        if(result != null) {
                            networkView.setVisibility(View.GONE);
                            Intent customerDetailIntent = new Intent(this, CustomerDetailActivity.class);
                            customerDetailIntent.putExtra("customerobj", result);
                            SniperApplication.getApplication().setComingFromEquipmentNotification(true);
                            SniperApplication.getApplication().setSerialNoFromNotification(serialNo);
                            startActivity(customerDetailIntent);
                        } else {
                            Toast.makeText(this, "Customer Not Found.", Toast.LENGTH_SHORT).show();
                            networkView.setVisibility(View.GONE);
                        }
                    });
                }
            } else if(pushEventType == PushTypes.NEWS) {
                //Go to NEWS Detail & Start Loading..
                String newsId = intent.getExtras().getString("newsId", null);
                if(newsId != null) {
                    Utility.logUsage(LogConstants.Section.NOTIFICATION, LogConstants.Activity.NEWS_CLICKED, "newsId: " + newsId);
                    SniperApplication.getApplication().setComingFromNewsNotification(true);
                    SniperApplication.getApplication().setNewsIdFromNotification(newsId);
                    LocalBroadcastManager.getInstance(this).sendBroadcast(new Intent("NEWS_PUSH_RECEIVED"));
                }
            }
        }
    }

    private void markNotificationAsRead(String actionType, String messageId) {
        PushTokenManager pushTokenManager = new PushTokenManager(this);
        InboxService inboxService = new InboxService();
        MessageEventRequest request = MessageEventRequest.getActionClickedEvent(actionType, messageId, Util.getUserAgent(), pushTokenManager.getLastRegisteredPushToken());
        inboxService.sendMessageEvent(request, (result, t) -> {
            int currentUnreadMessages = pushTokenManager.getNotificationBadgeCount();
            if(currentUnreadMessages > 0) {
                currentUnreadMessages -= 1;
                pushTokenManager.saveNotificationBadgeCount(currentUnreadMessages);
                LocalBroadcastManager.getInstance(this).sendBroadcast(new Intent("PUSH_BADGE_UPDATED"));
            }
        });
    }

    private void sendPushNotificationClickedEvent(String actionType, String messageId, String actionUrl) {
        String lastRegisteredPushToken = new PushTokenManager(this).getLastRegisteredPushToken();
        MessageEventRequest request = MessageEventRequest.getActionClickedEvent(actionType, messageId, Util.getUserAgent(), lastRegisteredPushToken);
        MessageEventRequest pushClickedRequest = MessageEventRequest.newPushClicked(messageId, Util.getUserAgent(), lastRegisteredPushToken);
        InboxService inboxService = new InboxService();
        inboxService.sendMessageEvent(request, (result,t)->{});
        inboxService.sendMessageEvent(pushClickedRequest, (result,t)->{});
    }

    private boolean isFromPushNotification(Intent intent) {
        return intent.getBooleanExtra("IS_NOTIFICATION", false);
    }

    public static Intent newIntent(Context context, String actionType, String actionUrl, String title, boolean isSSO) {
        Intent intent = new Intent(context, MainActivity.class);
        intent.putExtra("actionType", actionType);
        intent.putExtra("actionUrl", actionUrl);
        intent.putExtra("title", title);
        intent.putExtra("sso", isSSO);
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return intent;
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (intent != null && intent.getExtras() != null) {
            prpWebContent(intent);
        }
    }

    private String getTitleForSection(String section) {
        if (Section.NEWS.equalsIgnoreCase(section)) {
            return getString(R.string.fragGuncel);
        } else if (Section.REPORTS.equalsIgnoreCase(section)) {
            return getString(R.string.fragReports);
        } else if (Section.CATALOGS.equalsIgnoreCase(section)) {
            return getString(R.string.fragCatalogs);
        } else if (Section.CUSTOMER.equalsIgnoreCase(section)) {
            return getString(R.string.fragCustomer);
        } else if (Section.OFFER.equalsIgnoreCase(section)) {
            return getString(R.string.fragOffer);
        } else if (Section.ROUTE.equalsIgnoreCase(section)) {
            return getString(R.string.fragRoute);
        } else if (Section.EXPERTISE.equalsIgnoreCase(section)) {
            return getString(R.string.fragExpertise);
        } else if (Section.MACHINE_SEARCH.equalsIgnoreCase(section)) {
            return getString(R.string.fragMachSearch);
        } else if (Section.MACHINE_SELECTION_WIZARD.equalsIgnoreCase(section)) {
            return getString(R.string.fragMachineWizard);
        } else if (Section.CATAPULT.equalsIgnoreCase(section)) {
            return getString(R.string.fragCatapult);
        } else if (Section.SNIPER_SURVEY.equalsIgnoreCase(section)) {
            return getString(R.string.fragSniperSurvey);
        } else if (Section.CUSTOMER_FIELD_WORK.equalsIgnoreCase(section)) {
            return getString(R.string.fragCustomerFieldWork);
        } else if (Section.ACTIVITY.equalsIgnoreCase(section)) {
            return getString(R.string.fragActivity);
        } else if (Section.LEAD.equalsIgnoreCase(section)) {
            return getString(R.string.fragLead);
        } else if (Section.OPPORTUNITY.equalsIgnoreCase(section)) {
            return getString(R.string.fragOpportunity);
        } else if (Section.CUSTOMERFIORI.equalsIgnoreCase(section)) {
            return getString(R.string.fragCustomer);
        } else if (Section.RELATED_PERSON.equalsIgnoreCase(section)) {
            return getString(R.string.fragRelatedPerson);
        } else if (Section.BDAHA.equalsIgnoreCase(section)) {
            return getString(R.string.fragBDaha);
        } else if (Section.SPARE_PART_ORDERS.equalsIgnoreCase(section)) {
            return getString(R.string.fragSparePartOrders);
        } else if (Section.SPARE_PART_STOCK_STATUS.equalsIgnoreCase(section)) {
            return getString(R.string.fragSparePartStockStatus);
        } else if (Section.COMPAINTS_MANAGEMENT.equalsIgnoreCase(section)) {
            return getString(R.string.fragComplaintManagement);
        } else if (Section.SERVICE_DEMANDS.equalsIgnoreCase(section)) {
            return getString(R.string.fragServiceDemands);
        } else if (Section.WORKSHOP_OPERATIONS.equalsIgnoreCase(section)) {
            return getString(R.string.fragWorkshopOperations);
        } else if (Section.COMPETITOR_SPARE_PART_PRICE.equalsIgnoreCase(section)) {
            return getString(R.string.fragCompetitorSparePartPrice);
        } else if (Section.SERVICE_REQUEST_APPROVAL.equalsIgnoreCase(section)) {
            return getString(R.string.fragServiceDocumentApproval);
        } else if (Section.SERVICE_OFFER_APPROVAL.equalsIgnoreCase(section)) {
            return getString(R.string.fragServiceOfferApproval);
        } else if (Section.CHECK_IN.equalsIgnoreCase(section)) {
            return getString(R.string.fragCheckIn);
        } else if (Section.CVA.equalsIgnoreCase(section)) {
            return getString(R.string.fragCVA);
        }

        return section;
    }

    private void setIconForSection(String section, MenuItem item) {
        int drawableIcon = 0;

        if (Section.NEWS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_haberler;
        } else if (Section.REPORTS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_raporlar;
        } else if (Section.CATALOGS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_katalog;
        } else if (Section.MACHINE_SELECTION_WIZARD.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_compare_arrows_24px;
        } else if (Section.CATAPULT.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_calculate_white_24dp;
        }  else if (Section.SNIPER_SURVEY.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_survey;
        } else if (Section.CUSTOMER_FIELD_WORK.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_form_white_24dp;
        } else if (Section.CUSTOMER.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_musteriler;
        } else if (Section.OFFER.equalsIgnoreCase(section)) {//teklif
            drawableIcon = R.drawable.ic_icon_teklifler;
        } else if (Section.ROUTE.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_rota_planlama;
        } else if (Section.EXPERTISE.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_ekspertiz;
        } else if (Section.MACHINE_SEARCH.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_icon_makina_arama;
        } else if (Section.ACTIVITY.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_access_time_white_24px;
        } else if (Section.LEAD.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_baseline_bar_chart_24;
        } else if (Section.OPPORTUNITY.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_baseline_whatshot_24;
        } else if (Section.CUSTOMERFIORI.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_baseline_supervisor_account_24;
        } else if (Section.RELATED_PERSON.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_baseline_contacts_24;
        } else if (Section.BDAHA.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_baseline_build_24;
        } else if (Section.SPARE_PART_ORDERS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_spare_part_order;
        } else if (Section.SPARE_PART_STOCK_STATUS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_spare_part_stock_status;
        } else if (Section.COMPAINTS_MANAGEMENT.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_complaints_management;
        } else if (Section.SERVICE_DEMANDS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_service_demand;
        } else if (Section.WORKSHOP_OPERATIONS.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_workshop_operations;
        } else if (Section.COMPETITOR_SPARE_PART_PRICE.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_competitor_sqare_part_price;
        } else if (Section.SERVICE_REQUEST_APPROVAL.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_assignment_turned_in_black_24dp;
        } else if (Section.SERVICE_OFFER_APPROVAL.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_assignment_turned_in_black_24dp;
        } else if (Section.CHECK_IN.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_location_on_black_24dp;
        } else if (Section.CVA.equalsIgnoreCase(section)) {
            drawableIcon = R.drawable.ic_customer_value_agreement;
        }

        Drawable dr = getResources().getDrawable(drawableIcon);
        dr.setColorFilter(getResources().getColor(R.color.black), PorterDuff.Mode.SRC_IN);
        item.setIcon(dr);
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.contentMainLayout);
            if (fragment != null && fragment instanceof OnBackPressListener) {
                OnBackPressListener backPressListener = (OnBackPressListener) fragment;
                if (backPressListener.onBackPressed()) {
                    getSupportFragmentManager().popBackStack();
                    return;
                }
            }
            showExitDialog();
        }
    }

    private void showExitDialog() {
        AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
        builder1.setMessage(getString(R.string.dialog_want_to_quit));
        builder1.setCancelable(true);

        builder1.setTitle(getString(R.string.app_name));
        builder1.setIcon(R.drawable.ic_exit_to_app_black_24px);

        builder1.setPositiveButton(
                getString(R.string.dialog_yes),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Utility.clearAllData(MainActivity.this);
                        Intent i = new Intent(getApplicationContext(), SplashActivity.class);
                        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                        //i.putExtra("latestLanguage", SniperUser.getInstance().languageCode);
                        startActivity(i);
                    }
                });

        builder1.setNegativeButton(
                getString(R.string.dialog_cancel),
                (dialog, id) -> dialog.cancel());


        builder1.setNeutralButton(getString(R.string.exit_move_back),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        moveTaskToBack(true);
                    }
                });


        AlertDialog alert11 = builder1.create();
        alert11.show();
    }

 /*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_logout) {
            showExitDialog();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }*/

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        loadFragment(id);
        return true;
    }

    public void hideKeyboard() {
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) this.getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    public void loadFragment(int id) {
        Fragment fragment = null;
        hideKeyboard();
        if (isInclude(id, Section.NEWS)) {
            setTitle(getTitleForSection(Section.NEWS));
            fragment = NewsFragment.newInstance();
        } else if (isInclude(id, Section.CUSTOMER)) {
            setTitle(getTitleForSection(Section.CUSTOMER));
            fragment = CustomerFragment.newInstance();
        } else if (isInclude(id, Section.MACHINE_SEARCH)) {
            setTitle(getTitleForSection(Section.MACHINE_SEARCH));
            fragment = MachineSearchFragment.newInstance();
        } else if (isInclude(id, Section.CATALOGS)) {
            setTitle(getTitleForSection(Section.CATALOGS));
            fragment = CatalogFragment.newInstance();
        } else if (isInclude(id, Section.MACHINE_SELECTION_WIZARD)) {
            setTitle(getTitleForSection(Section.MACHINE_SELECTION_WIZARD));
            fragment = MachineWizardFragment.newInstance();
        } else if (isInclude(id, Section.CUSTOMER_FIELD_WORK)) {
            setTitle(getTitleForSection(Section.CUSTOMER_FIELD_WORK));
            fragment = CustomerFieldWorkFragment.newInstance();
        } else if (isInclude(id, Section.CATAPULT)) {
            setTitle(getTitleForSection(Section.CATAPULT));
            fragment = CatapultFragment.newInstance();
        } else if (isInclude(id, Section.OFFER)) {
            setTitle(getTitleForSection(Section.OFFER));
            fragment = ProposalFragment.newInstance();
        } else if (isInclude(id, Section.EXPERTISE)) {
            setTitle(getTitleForSection(Section.EXPERTISE));
            fragment = ExpertiseFragment.newInstance();
        } else if (isInclude(id, Section.REPORTS)) {
            setTitle(getTitleForSection(Section.REPORTS));
            fragment = ReportFragment.newInstance();
        } else if (isInclude(id, Section.ROUTE)) {
            setTitle(getTitleForSection(Section.ROUTE));
            fragment = RouteFragment.newInstance();
        } else if (isInclude(id, Section.SPARE_PART_ORDERS)) {
            setTitle(getTitleForSection(Section.SPARE_PART_ORDERS));
            fragment = SparePartOrderFragment.newInstance();
        } else if (isInclude(id, Section.SPARE_PART_STOCK_STATUS)) {
            setTitle(getTitleForSection(Section.SPARE_PART_STOCK_STATUS));
            fragment = SparePartStockStatusFragment.newInstance();
        } else if (isInclude(id, Section.COMPAINTS_MANAGEMENT)) {
            setTitle(getTitleForSection(Section.COMPAINTS_MANAGEMENT));
            fragment = CompaintFragment.newInstance();
        } else if (isInclude(id, Section.SERVICE_DEMANDS)) {
            setTitle(getTitleForSection(Section.SERVICE_DEMANDS));
            fragment = ServiceDemandFragment.newInstance();
        } else if (isInclude(id, Section.WORKSHOP_OPERATIONS)) {
            setTitle(getTitleForSection(Section.WORKSHOP_OPERATIONS));
            fragment = WorkshopOperationFragment.newInstance();
        } else if (isInclude(id, Section.COMPETITOR_SPARE_PART_PRICE)) {
            setTitle(getTitleForSection(Section.COMPETITOR_SPARE_PART_PRICE));
            fragment = CompetitorSparePartPriceFragment.newInstance();
        } else if (isInclude(id, Section.SERVICE_REQUEST_APPROVAL)) {
            setTitle(getTitleForSection(Section.SERVICE_REQUEST_APPROVAL));
            fragment = ServiceDocumentApprovalFragment.newInstance();
        } else if (isInclude(id, Section.SERVICE_OFFER_APPROVAL)) {
            setTitle(getTitleForSection(Section.SERVICE_OFFER_APPROVAL));
            fragment = ServiceQuotationApprovalFragment.newInstance();
        } else if (isInclude(id, Section.ACTIVITY)) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().activityUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.ACTIVITY), false);
        } else if (isInclude(id, Section.LEAD)) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().leadUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.LEAD), false);
        } else if (isInclude(id, (Section.OPPORTUNITY))) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().opportunityUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.OPPORTUNITY), false);
        } else if (isInclude(id, Section.CUSTOMERFIORI)) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().customerUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.CUSTOMERFIORI), false);
        } else if (isInclude(id, Section.RELATED_PERSON)) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().relatedPersonUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.RELATED_PERSON), false);
        } else if (isInclude(id, Section.BDAHA)) {
            String url = SniperUser.getSSOUrl(SniperUser.getInstance().bDahaUrl);
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.BDAHA), false);
        } else if (isInclude(id, Section.CHECK_IN)) {
            if (Utility.isLocationServiceEnabled(this)) {
                setTitle(getTitleForSection(Section.CHECK_IN));
                fragment = CheckInMapFragment.newInstance();
            } else {
                CheckInService checkInService = new CheckInService();
                checkInService.showLocationServiceDialog(this);
            }
        } else if (isInclude(id, "Logout")) {
            showExitDialog();
        } else if (isInclude(id, "Survey")) {
            String url = SniperUser.getInstance().sniperSurveyUrl;
            Utility.logUsage(LogConstants.Section.SNIPER_SURVEY, LogConstants.Activity.VIEW_SNIPER_SURVEY, "");
            fragment = WebContentFragment.newInstance(url, getTitleForSection(Section.SNIPER_SURVEY), true);
        } else if (isInclude(id, Section.CVA)) {
            Utility.logUsage(LogConstants.Section.CVA, LogConstants.Activity.VIEW_CVA, "");
            if(SniperUser.getInstance().urlCVACalculator != null && !SniperUser.getInstance().urlCVACalculator.isEmpty()) {
                fragment = WebContentFragment.newInstance(SniperUser.getInstance().urlCVACalculator, getTitleForSection(Section.CVA), true);
            }
        }

        handleMainAppBarAppearance(fragment);
        if (fragment != null) {
            final Fragment finalFragment = fragment;
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    FragmentManager manager = getSupportFragmentManager();
                    FragmentTransaction transaction = manager.beginTransaction().setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
                    transaction.replace(R.id.contentMainLayout, finalFragment);
                    transaction.commit();
                }
            }, 300);
        }
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
    }

    private void handleMainAppBarAppearance(Fragment fragment) {
        if (fragment instanceof HasOwnAppBar) {
            HasOwnAppBar hasOwnAppBarFragment = (HasOwnAppBar) fragment;
            mainAppBar.setVisibility(hasOwnAppBarFragment.showMainAppBar() ? View.VISIBLE : View.GONE);
            ViewCompat.setElevation(mainAppBar, hasOwnAppBarFragment.showMainAppBarShadow() ? (float) Utility.dpToPx(8) : 0);
        } else {
            mainAppBar.setVisibility(View.VISIBLE);
            ViewCompat.setElevation(mainAppBar, (float) Utility.dpToPx(8));
        }
    }

    public boolean isInclude(int id, String key) {
        boolean result = false;
        if (fragidMap.containsKey(key)) {
            if (fragidMap.get(key) == id) {
                result = true;
            }
        }
        return result;
    }

    public void fetchDataFromService() {
        showProgressDialog();
        //MenuItem menuItem = DataTransfer.getInstance().getData(DataKeys.SERVICE_DOCUMENT_MENU_ITEM, MenuItem.class);
        MenuItem serviceQuotationApprovalMenuItem = DataTransfer.getInstance().getData(DataKeys.SERVICE_QUOTATION_MENU_ITEM, MenuItem.class);

        BaseService baseService = new BaseService();
        Observable<CitiesResponse> cityListObservable = baseService.ibs.getCities(baseService.auth, baseService.username).toObservable();
        Observable<BaseResponse<SIMApprovals>> simApprovalsObservable;
        Observable<BaseResponse<ServiceQuotationListResponse>> serviceQuotationApprovalsObservable;
        String[] initServiceStatusFilters = { ServiceQuotationStatus.ONPSSR.getValue(), ServiceQuotationStatus.WAITINGFORBILLINGAPRROVAL.getValue() };

        if (serviceQuotationApprovalMenuItem != null) {
            //simApprovalsObservable = baseService.ibs.simApprovals(baseService.auth, baseService.username).toObservable();
            serviceQuotationApprovalsObservable = baseService.ibs.getSingleServiceQuotations(baseService.auth, baseService.username, "", Arrays.asList(initServiceStatusFilters)).toObservable();
        } else {
            //simApprovalsObservable = Observable.empty();
            serviceQuotationApprovalsObservable = Observable.empty();
        }

        //Parallel requests
        //The mergeDelayError method is the same as merge in that it combines multiple Observables into one, but if errors occur during the merge, it allows error-free items to continue before propagating the errors:
        Disposable disposable = Observable.mergeDelayError(
                cityListObservable.subscribeOn(Schedulers.io()),
                //simApprovalsObservable.subscribeOn(Schedulers.io()),
                serviceQuotationApprovalsObservable.subscribeOn(Schedulers.io()))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(it -> {
                    if (it != null) {
                        if (it.getData() instanceof CitiesResponse.CityData) {
                            CitiesResponse response = (CitiesResponse) it;
                            CityList.getInstance().setCityData(response.getData());

                        } /*else if (it.getData() instanceof SIMApprovals && menuItem != null) {
                            SIMApprovals data = (SIMApprovals) it.getData();
                            int count = SIMApprovalsAdapter.countPendingApprovals(data.getSimApprovalList());
                            if (count > 0) {
                                String title = getString(R.string.fragServiceDocumentApproval);
                                menuItem.setTitle(title + " (" + count + ")");
                            }
                        }*/ else if (it.getData() instanceof ServiceQuotationListResponse && serviceQuotationApprovalMenuItem != null) {
                            ServiceQuotationListResponse data = (ServiceQuotationListResponse) it.getData();
                            if (data.getServiceQuotations() != null && data.getServiceQuotations().size() > 0) {
                                String title = getString(R.string.fragServiceOfferApproval);
                                serviceQuotationApprovalMenuItem.setTitle(title + " (" + data.getServiceQuotations().size() + ")");
                            }
                        }
                    }
                }, throwable -> {
                    //OnError
                    hideProgressDialog();
                    Log.e("Request Error", throwable.getMessage(), throwable);
                }, () -> {
                    //OnComplete
                    hideProgressDialog();
                    System.out.println("All request Completed");
                });

        addDisposable(disposable);
    }

    boolean isAppListeningNotifications = true;
    @Override
    protected void onResume() {
        super.onResume();
        Utility.checkVersion(MainActivity.this);
        if(!isAppListeningNotifications) {
            isAppListeningNotifications = true;
            listenPushNotifications();
        }

        PushTokenManager pushTokenManager = new PushTokenManager(this);
        int lastUnreadMessageCount = pushTokenManager.getNotificationBadgeCount();
        if(lastUnreadMessageCount > 0) {
            layoutNotificationBubble.setVisibility(View.VISIBLE);
            tvNotificationBadgeCount.setText(String.valueOf(lastUnreadMessageCount));
        } else {
            layoutNotificationBubble.setVisibility(View.GONE);
        }
    }

    @Override
    protected void onStop() {
        isAppListeningNotifications = false;
        LocalBroadcastManager.getInstance(this).unregisterReceiver(pushReceiver);
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(pushReceiver);
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            fragment.onActivityResult(requestCode, resultCode, data);
        }
    }

    private void syncMenu() {
        List<String> userSections = SniperUser.getInstance().sectionList;
        for(MenuItemEntity entity : menuItems) {
            entity.getItem().setVisible(userSections.contains(entity.getName()));
        }
    }

    private void checkIfNeedSaveLastPauseTime() {
        try {
            String lastUpdatedConfigDatetime = preferences.getString("lastLoginCheckDatetime", null);
            if(lastUpdatedConfigDatetime == null) {
                String currentDateTime = Utility.getCurrentStatusDatewithUTC();
                SharedPreferences.Editor editor = preferences.edit();
                editor.putString("lastLoginCheckDatetime", currentDateTime);
                editor.apply();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void checkIfNeedReloadUserConfigs() {
        String lastUpdatedConfigDatetime = preferences.getString("lastLoginCheckDatetime", null);
        if(lastUpdatedConfigDatetime != null) {
            double hourDifference = Utility.getHourDifferenceBetweenDates(Utility.getCurrentStatusDatewithUTC(), lastUpdatedConfigDatetime);
            if(hourDifference >= 12) {
                authService.checkAuthStatusPeriodically((isLoggedIn, error) -> {
                    if(isLoggedIn) {
                        syncMenu();

                        String currentDateTime = Utility.getCurrentStatusDatewithUTC();
                        SharedPreferences.Editor editor = preferences.edit();
                        editor.putString("lastLoginCheckDatetime", currentDateTime);
                        editor.apply();
                    }
                });
            }
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void appInResumeState() {
        if(appIsBackground) {
            appIsBackground = false;
            checkIfNeedReloadUserConfigs();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void appInPauseState() {
        checkIfNeedSaveLastPauseTime();
        appIsBackground = true;
    }
}
