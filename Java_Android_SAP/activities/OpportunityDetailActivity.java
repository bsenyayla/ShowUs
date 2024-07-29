package com.san.sniper.activities;

import android.content.Context;
import android.content.Intent;
import androidx.databinding.DataBindingUtil;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import android.view.MenuItem;

import com.san.sniper.R;
import com.san.sniper.databinding.ActivityOpportunityDetailBinding;
import com.san.sniper.responsepojos.Opportunity;

public class OpportunityDetailActivity extends BaseActivity {


    private static final String BUNDLE_USERNAME = "BUNDLE_USERNAME";
    private static final String BUNDLE_OPPORTUNITY = "BUNDLE_OPPORTUNITY";
    private ActivityOpportunityDetailBinding binding;

    public static void startOpportunityDetail(Context context, String username, Opportunity opportunity) {
        Intent intent = new Intent(context, OpportunityDetailActivity.class);
        intent.putExtra(BUNDLE_USERNAME, username);
        intent.putExtra(BUNDLE_OPPORTUNITY, opportunity);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = DataBindingUtil.setContentView(this, R.layout.activity_opportunity_detail);
        setSupportActionBar(binding.toolbar);
        initializeUI();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home){
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void initializeUI() {
        binding.setItem(getOpportunity());
        binding.executePendingBindings();
    }

    public String getUsername(){
        return getIntent().getStringExtra(BUNDLE_USERNAME);
    }

    public Opportunity getOpportunity(){
        return getIntent().getParcelableExtra(BUNDLE_OPPORTUNITY);
    }

}
