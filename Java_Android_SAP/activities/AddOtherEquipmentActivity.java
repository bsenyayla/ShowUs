package com.san.sniper.activities;

import android.app.SearchManager;
import android.os.Bundle;
import androidx.core.view.MenuItemCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.SearchView;
import androidx.appcompat.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ProgressBar;

import com.san.sniper.DataKeys;
import com.san.sniper.R;
import com.san.sniper.adapters.AddOtherEquipmentAdapter;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.interfaces.IsanServices;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.OtherEquipment;
import com.san.sniper.service.BaseService;
import com.san.sniper.singletons.DataTransfer;

import java.util.ArrayList;
import java.util.List;

import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import retrofit2.Call;
import retrofit2.Retrofit;

public class AddOtherEquipmentActivity extends BaseActivity {

    AddOtherEquipmentAdapter adapter;
    RecyclerView myRecycleView;
    SearchView mSearchView;
    String customerID = "";
    ProgressBar mProgressBar;
    SwipeRefreshLayout swipeRefreshLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_equipment);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        String title = getIntent().getExtras().getString("title", "");
        customerID = getIntent().getExtras().getString("customerID", "");
            getSupportActionBar().setTitle(title);

        mProgressBar = (ProgressBar) findViewById(R.id.mProgressBar);
        myRecycleView = (RecyclerView) findViewById(R.id.myRecycleView);
        myRecycleView.setLayoutManager(new LinearLayoutManager(this));
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeContainer);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                DataTransfer.getInstance().putData(DataKeys.OTHER_EQUIPMENTS,null);
                initDataSet();
            }
        });

        initDataSet();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == android.R.id.home) {
            finish(); // close this activity and return to preview activity (if there is any)
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.other_equipment_menu, menu);
        mSearchView = (SearchView) MenuItemCompat.getActionView(menu.findItem(R.id.action_search));
        mSearchView.setQueryHint(getString(R.string.search)+"...");
        SearchManager searchManager = (SearchManager) getSystemService(SEARCH_SERVICE);
        mSearchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                callSearch(query);
                return true;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                callSearch(newText);
                return true;
            }

            public void callSearch(String query) {
                if (adapter != null)
                    adapter.getFilter().filter(query);
            }

        });

        return super.onCreateOptionsMenu(menu);
    }


    public void initDataSet() {
        List<OtherEquipment> equipments = DataTransfer.getInstance().getData(DataKeys.OTHER_EQUIPMENTS,List.class);
        if( equipments != null){
            populateData(equipments);
        }else{
            BaseService baseService = new BaseService();
            if(!swipeRefreshLayout.isRefreshing())
                mProgressBar.setVisibility(View.VISIBLE);
            Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
            IsanServices ibs = retrofit.create(IsanServices.class);
            Call<BaseResponse<ArrayList<OtherEquipment>>> call = ibs.getOtherEquipments(baseService.auth, baseService.username);
            baseService.callRequest(call, (otherEquipmentResponse, t) -> {
                if(otherEquipmentResponse != null){
                    if(otherEquipmentResponse.isSuccessful()){
                        populateData(otherEquipmentResponse.getData());
                        DataTransfer.getInstance().putData(DataKeys.OTHER_EQUIPMENTS,otherEquipmentResponse.getData());
                    }else{
                        String message = otherEquipmentResponse.messagesToString();
                        showError(message);
                    }
                }else if(t != null){
                    showError(t.getMessage());
                    Log.e("AddOtherEquipment",t.getMessage(),t);
                }
                if(swipeRefreshLayout.isRefreshing()){
                    swipeRefreshLayout.setRefreshing(false);
                }else{
                    mProgressBar.setVisibility(View.GONE);
                }
            });
        }
    }

    private void populateData(List<OtherEquipment> otherEquipmentList){
        adapter = new AddOtherEquipmentAdapter(otherEquipmentList,customerID,AddOtherEquipmentActivity.this);
        myRecycleView.setAdapter(adapter);
        adapter.notifyDataSetChanged();
    }


}
