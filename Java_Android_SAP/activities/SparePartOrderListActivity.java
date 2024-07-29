package com.san.sniper.activities;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.core.view.MenuItemCompat;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.SearchView;
import androidx.appcompat.widget.Toolbar;

import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;

import com.san.sniper.LogConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.SparePartOrderListAdapter;
import com.san.sniper.fragments.SqarePartListDetailFragment;
import com.san.sniper.interfaces.RecyclerItemClickListener;
import com.san.sniper.responsepojos.response.SparePartOrderResponse;
import com.san.sniper.responsepojos.sparepartorder.PssrOrderItem;
import com.san.sniper.singletons.DataTransfer;

import java.util.ArrayList;

public class SparePartOrderListActivity extends BaseActivity {

    private static final String BUNDLE_ORDER_LIST = "BUNDLE_ORDER_LIST";
    SearchView mSearchView;
    SparePartOrderListAdapter adapter;
    RecyclerView myRecycleView;
    FrameLayout myContent;
    FragmentTransaction fragmentTransaction;
    ArrayList<SparePartOrderResponse.Orders> ordersArrayList;
    SqarePartListDetailFragment sqarePartListDetailFragment;
    FragmentManager fragmentManager;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_spare_part_order_list);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        myRecycleView = (RecyclerView)findViewById(R.id.myRecycleView);
        myContent = (FrameLayout) findViewById(R.id.myContent);
        ordersArrayList = getOrders();
        fragmentManager = getSupportFragmentManager();
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        myRecycleView.setLayoutManager(linearLayoutManager);
        setTitle(setupDefaultTitle());

        adapter = new SparePartOrderListAdapter(ordersArrayList);
        myRecycleView.setAdapter(adapter);
        myRecycleView.addOnItemTouchListener(
                new RecyclerItemClickListener(this, myRecycleView, new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        ArrayList<PssrOrderItem> mylist = ordersArrayList.get(position).getOrderItems();

                        setTitle(Utility.trimLeadingZeros(ordersArrayList.get(position).getDocumentNo()));
                        Utility.logUsage(LogConstants.Section.SPARE_PART_ORDER, LogConstants.Activity.OPEN_SPARE_PART_DETAIL,"orderNumber:"+ordersArrayList.get(position).getDocumentNo());

                        myContent.setVisibility(View.VISIBLE);
                        sqarePartListDetailFragment = SqarePartListDetailFragment.newInstance(mylist);
                        fragmentTransaction = fragmentManager.beginTransaction();
                        fragmentTransaction.replace(R.id.myContent, sqarePartListDetailFragment);
                        fragmentTransaction.addToBackStack(null).commit();

                    }

                    @Override
                    public void onLongItemClick(View view, int position) {

                    }
                })
        );



    }

    private String setupDefaultTitle() {
        return getString(R.string.lbl_work_shop_search_result);
    }

    @Override
    public void onBackPressed() {
        prpBackStack();
    }

    private void prpBackStack() {
        int count = fragmentManager.getBackStackEntryCount();
        if (count == 0) {
            super.onBackPressed();
        } else {
            myContent.setVisibility(View.GONE);
            fragmentManager.popBackStackImmediate();
            setTitle(setupDefaultTitle());

        }

    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                prpBackStack();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }


    public static void startSparePartOrderListActivity(Context context, ArrayList<SparePartOrderResponse.Orders> orderlist,String loginfo) {
        Intent intent = new Intent(context, SparePartOrderListActivity.class);
        //intent.putParcelableArrayListExtra(BUNDLE_ORDER_LIST, orderlist); //android.os.TransactionTooLargeException
        DataTransfer.getInstance().putData("SparePartOrderList",orderlist);
        context.startActivity(intent);
    }

    public ArrayList<SparePartOrderResponse.Orders> getOrders() {
        ArrayList<SparePartOrderResponse.Orders> orderlist = DataTransfer.getInstance().getData("SparePartOrderList",ArrayList.class);
        if(orderlist==null){
            orderlist = new ArrayList<>();
        }
        return orderlist;
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        getMenuInflater().inflate(R.menu.appbar_searchview, menu);
        mSearchView = (SearchView) MenuItemCompat.getActionView(menu.findItem(R.id.action_search));
        mSearchView.setQueryHint(getString(R.string.search)+"...");
        SearchManager searchManager = (SearchManager) this.getSystemService(SEARCH_SERVICE);
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

        return true;


    }


}
