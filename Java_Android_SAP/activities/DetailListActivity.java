package com.san.sniper.activities;

import android.os.Bundle;
import android.view.MenuItem;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.san.sniper.R;
import com.san.sniper.adapters.DetailListAdapter;
import com.san.sniper.responsepojos.notification.DetailTypePushNotificationResponse;
import java.util.ArrayList;

@SuppressWarnings("unchecked")
public class DetailListActivity extends BaseActivity {

    private ArrayList<DetailTypePushNotificationResponse> detailItems;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail_list);
        detailItems = (ArrayList<DetailTypePushNotificationResponse>) getIntent().getSerializableExtra("detailitems");
        initializeToolbar();
        initializeRecyclerView();
    }

    private void initializeToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.title_detail_list);
    }

    private void initializeRecyclerView() {
        final RecyclerView recyclerView = findViewById(R.id.rvDetailList);
        recyclerView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        DetailListAdapter adapter = new DetailListAdapter(detailItems);
        recyclerView.setAdapter(adapter);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
        }
        return super.onOptionsItemSelected(item);
    }
}
