package com.san.sniper.activities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.san.sniper.R;
import com.san.sniper.adapters.CustomerFieldWorkDetailAdapter;
import com.san.sniper.responsepojos.customerfieldwork.CustomerFieldWorkResponse;

import java.util.ArrayList;
import java.util.List;

public class CustomerFieldWorkDetailActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_customer_field_work_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        CustomerFieldWorkResponse customerFieldWork = getIntent().getExtras().getParcelable("customerFieldWork");
        getSupportActionBar().setTitle(getString(R.string.fragCustomerFieldWork));

        TextView txtBrand = findViewById(R.id.txtBrand);
        TextView  txtModel= findViewById(R.id.txtModel);
        TextView  txtCreatedDate = findViewById(R.id.txtCreatedDate);
        TextView txtCreatedBy = findViewById(R.id.txtCreatedBy);
        TextView customerName=findViewById(R.id.customerName);

        txtBrand.setText(customerFieldWork.getBrand());
        txtModel.setText(customerFieldWork.getModel());
        txtCreatedDate.setText(customerFieldWork.getCreatedDate());
        txtCreatedBy.setText(customerFieldWork.getCreator());
        customerName.setText(customerFieldWork.getCustomerName());

        RecyclerView myRecycleView = findViewById(R.id.myRecycleView);
        RecyclerView myRecycleViewOther = findViewById(R.id.myRecycleViewOther);

        myRecycleView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
        myRecycleViewOther.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));

        ArrayList<CustomerFieldWorkResponse.FileItem> list = new ArrayList<>();
        ArrayList<CustomerFieldWorkResponse.FileItem> list2 = new ArrayList<>();
        for (int i = 0; i <customerFieldWork.getFileItems().size() ; i++) {
            CustomerFieldWorkResponse.FileItem fileItem = customerFieldWork.getFileItems().get(i);
            if(fileItem.getFileType()==1){
                list2.add(fileItem);
            }else {
                list.add(fileItem);

            }
        }


        if(list.size()>0){
            findViewById(R.id.field_work_files).setVisibility(View.VISIBLE);
        }else {
            findViewById(R.id.field_work_files).setVisibility(View.INVISIBLE);
        }

        if(list2.size()>0){
            findViewById(R.id.field_work_files_other).setVisibility(View.VISIBLE);
        }else {
            findViewById(R.id.field_work_files_other).setVisibility(View.INVISIBLE);
        }

        CustomerFieldWorkDetailAdapter customerFieldWorkDetailAdapter = new CustomerFieldWorkDetailAdapter(list);
        CustomerFieldWorkDetailAdapter customerFieldWorkDetailAdapter2 = new CustomerFieldWorkDetailAdapter(list2);

        myRecycleView.setAdapter(customerFieldWorkDetailAdapter);
        myRecycleViewOther.setAdapter(customerFieldWorkDetailAdapter2);


    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home){
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}