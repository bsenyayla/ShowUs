package com.san.sniper.activities;

import android.content.Intent;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import android.os.Bundle;
import android.view.MenuItem;

import com.san.sniper.R;
import com.san.sniper.fragments.CheckInFragments.ActivityDetailFragment;
import com.san.sniper.fragments.CheckInFragments.ActivityListFragment;
import com.san.sniper.fragments.CheckInFragments.CreateActivityFragment;
import com.san.sniper.responsepojos.checkin.ActivityAddress;

public class CheckInManagementActivity extends BaseActivity {
    public static final String TO_VIEW_TAG = "TO_VIEW_TAG";
    public static final String ACTIVITY_ADDRESS = "ACTIVITY_ADDRESS";
    public static final String ACTIVITY_OBJECT_ID = "ACTIVITY_OBJECT_ID";

    public static final String FRAGMENT_ACTIVITY_LIST = "FRAGMENT_ACTIVITY_LIST";
    public static final String FRAGMENT_CREATE_CHECK_IN = "FRAGMENT_CREATE_CHECK_IN";
    public static final String FRAGMENT_ACTIVITY_DETAIL = "FRAGMENT_ACTIVITY_DETAIL";

    public String activeView = "";
    public ActivityAddress activityAddress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_in_management);
        if(getSupportActionBar() != null){
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle(R.string.check_in);
        }

        Intent intent = getIntent();
        if (intent != null) {
            activeView = intent.getStringExtra(TO_VIEW_TAG);
            activityAddress = intent.getParcelableExtra(ACTIVITY_ADDRESS);
        }

        loadFragment(activeView);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            fragment.onActivityResult(requestCode, resultCode, data);
        }
    }


    public void loadFragment(String fragmentTag)  {
        Fragment fragment = null;

        switch (fragmentTag) {
            case FRAGMENT_CREATE_CHECK_IN:
                setTitle(R.string.create_check_in);
                fragment = CreateActivityFragment.newInstance(activityAddress);
                break;
            case FRAGMENT_ACTIVITY_LIST:
                if(activityAddress == null){
                    fragment = ActivityListFragment.newInstance(true,true); // User check-in history
                    setTitle(R.string.my_activities);
                }else{
                    fragment = ActivityListFragment.newInstance(activityAddress.getCustomerNo(),activityAddress.getTitle()); // Customer check-in history
                    setTitle(R.string.title_customer_activity_history);
                }

                break;
            case FRAGMENT_ACTIVITY_DETAIL:
                Intent intent = getIntent();
                String objectId = "";
                if (intent != null) {
                    objectId = intent.getStringExtra(ACTIVITY_OBJECT_ID);
                }
                setTitle(R.string.activity_detail);
                fragment = ActivityDetailFragment.newInstance(objectId);
                break;
            default:

        }
        if (fragment != null) {
            final Fragment finalFragment = fragment;
            FragmentManager manager = getSupportFragmentManager();
            FragmentTransaction transaction = manager.beginTransaction().setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
            transaction.replace(R.id.fragmentArea, finalFragment);
            transaction.commitAllowingStateLoss();
        }
    }

    @Override
    public void setTitle(CharSequence title) {
        if(getSupportActionBar() != null){
            getSupportActionBar().setTitle(title);
        }
    }

    @Override
    public void setTitle(int titleId) {
        if(getSupportActionBar() != null){
            getSupportActionBar().setTitle(titleId);
        }
    }
}
