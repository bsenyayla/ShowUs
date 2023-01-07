package com.san.sniper.activities;

import android.content.Intent;
import android.os.Bundle;
import com.google.android.material.tabs.TabLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.san.sniper.AppDatabase;
import com.san.sniper.R;
import com.san.sniper.singletons.ExpertiseSession;
import com.san.sniper.entity.ExpertiseFormWrapper;
import com.san.sniper.fragments.ExpertiseFragments.Expertise10Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise1Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise2Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise3Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise4Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise5Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise6Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise7Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise8Fragment;
import com.san.sniper.fragments.ExpertiseFragments.Expertise9Fragment;
import com.san.sniper.responsepojos.expertise.ExpertiseForm;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CreateExpertiseFormActivity extends BaseActivity {

    ViewPager viewPager;
    TabLayout tabLayout;
    private boolean viewMode = false;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_expertise_form);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setTitle(R.string.fragExpertise);

        viewMode = getIntent().getBooleanExtra("viewMode",false);

        viewPager = (ViewPager) findViewById(R.id.viewpager);
        setupViewPager(viewPager);
        tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(viewPager);
        int tabCount = tabLayout.getTabCount();

        String[] tabTextsArr = getResources().getStringArray(R.array.expertise_form_tabs);
        for (int i = 0; i < tabCount; i++) {
            TabLayout.Tab tab = tabLayout.getTabAt(i);
            View tabView = ((ViewGroup) tabLayout.getChildAt(0)).getChildAt(i);
            tabView.requestLayout();
            View myView = LayoutInflater.from(this).inflate(R.layout.custom_expertise_tabview, null);
            TextView txtStep = (TextView) myView.findViewById(R.id.txtStep);
            TextView txtInfo = (TextView) myView.findViewById(R.id.txtInfo);
            txtInfo.setEnabled(true);
            txtStep.setText(String.valueOf(i + 1));
            txtInfo.setText(tabTextsArr[i]);
            tab.setCustomView(myView);
        }

        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {

            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });
    }

    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(Expertise1Fragment.newInstance(viewMode), "1");
        adapter.addFragment(Expertise2Fragment.newInstance(viewMode), "2");
        adapter.addFragment(Expertise3Fragment.newInstance(viewMode), "3");
        adapter.addFragment(Expertise4Fragment.newInstance(viewMode), "4");
        adapter.addFragment(Expertise5Fragment.newInstance(viewMode), "5");
        adapter.addFragment(Expertise6Fragment.newInstance(viewMode), "6");
        adapter.addFragment(Expertise7Fragment.newInstance(viewMode), "7");
        adapter.addFragment(Expertise8Fragment.newInstance(viewMode), "8");
        adapter.addFragment(Expertise9Fragment.newInstance(viewMode), "9");
        adapter.addFragment(Expertise10Fragment.newInstance(viewMode), "10");
        viewPager.setAdapter(adapter);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public boolean onCreateOptionsMenu(Menu menu) {
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            fragment.onActivityResult(requestCode, resultCode, data);
        }
    }

    class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }


    @Override
    protected void onPause() {
        super.onPause();
        checkCompletedAndSaveDraft();
    }

    public void checkCompletedAndSaveDraft() {
        if (!ExpertiseSession.Instance().completed) {
            ExpertiseForm form = ExpertiseSession.Instance().form;
            if (form.getId() == null || form.getId().equals("")) {
                form.setId(UUID.randomUUID().toString());
            }
            Gson gson = new Gson();
            String formJson = gson.toJson(form);
            ExpertiseFormWrapper expertiseFormWrapper = new ExpertiseFormWrapper(form.getId(), formJson);
            AppDatabase.getAppDatabase(this).expertiseFormWrapperDao().insert(expertiseFormWrapper);
        }
    }


}
