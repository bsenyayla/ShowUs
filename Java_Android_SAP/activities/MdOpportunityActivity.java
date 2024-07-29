package com.san.sniper.activities;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.san.sniper.CreateOffer.CreateOfferActivity;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.OpportunityOffersAdapter;
import com.san.sniper.adapters.OpportunityProductsAdapter;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.requestpojos.quotation.CreateOfferRequestBody;
import com.san.sniper.requestpojos.quotation.OfferItem;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.mdopportunity.MdOpportunities;
import com.san.sniper.responsepojos.mdopportunity.MdOpportunity;
import com.san.sniper.responsepojos.mdopportunity.Offer;
import com.san.sniper.responsepojos.mdopportunity.OfferList;
import com.san.sniper.responsepojos.mdopportunity.Product;
import com.san.sniper.service.BaseService;


import java.util.Iterator;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MdOpportunityActivity extends BaseActivity {
    public static final String MD_OPPORTUNITIES_ID = "MD_OPPORTUNITIES_ID";
    protected Toolbar toolbar;
    protected TextView opportunityNo,definition,status,customer,estimatedVal,
            salesOffice,creationDate,customerNo,notes,expectedEndDate,
            maglev,relatedPerson,stage,successChange,opportunityGroup,source,priority,
            pssr,operationallyResponsible,model,serialNumber;
    MdOpportunity mdOpportunity = new MdOpportunity();
    List<Offer> opportunityOffers;
    Button createOfferBtn;

    RecyclerView items_RV,offers_RV;

    BaseService baseService = new BaseService();

    OpportunityOffersAdapter opportunityOffersAdapter;
    OpportunityProductsAdapter productsAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setContentView(R.layout.activity_md_opportunity);
        initView();
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        String mdOpportunityId = getIntent().getStringExtra(MD_OPPORTUNITIES_ID);
        if (mdOpportunityId != null){
            fetchMdOpportunities(mdOpportunityId,() -> {
                bindView();
                fetchOffers(mdOpportunityId,()->{
                    if(opportunityOffers != null){
                        opportunityOffersAdapter = new OpportunityOffersAdapter(opportunityOffers);
                        offers_RV.setAdapter(opportunityOffersAdapter);
                        opportunityOffersAdapter.notifyDataSetChanged();
                    }
                });
            });
        }
    }

    private void fetchOffers(String mdOpportunityId,Runnable onComplete) {
        showProgressDialog();
        Call<BaseResponse<OfferList>> mdOpportunityCall = RetrofitBuilder.getsanServices().getMdOpportunityOffers(baseService.auth, baseService.username,mdOpportunityId);
        mdOpportunityCall.enqueue(new Callback<BaseResponse<OfferList>>() {
            @Override
            public void onResponse(Call<BaseResponse<OfferList>> call, Response<BaseResponse<OfferList>> response) {
                if (response.isSuccessful() && response.body() != null && response.body().getData() != null) {
                    opportunityOffers = response.body().getData().getOffers();
                }
                hideProgressDialog();
                onComplete.run();
            }

            @Override
            public void onFailure(Call<BaseResponse<OfferList>> call, Throwable t) {
                hideProgressDialog();
                onComplete.run();
            }
        });
    }

    private void fetchMdOpportunities(String opportunityId,Runnable onComplete) {
        showProgressDialog();
        Call<BaseResponse<MdOpportunities>> opportunityCall = RetrofitBuilder.getsanServices().getMdOpportunityById(baseService.auth, baseService.username, opportunityId);
        opportunityCall.enqueue(new Callback<BaseResponse<MdOpportunities>>() {
            @Override
            public void onResponse(Call<BaseResponse<MdOpportunities>> call, Response<BaseResponse<MdOpportunities>> response) {
                if (response.isSuccessful() && response.body() != null && response.body().getData() != null) {
                    MdOpportunities opportunities = response.body().getData();
                    for(MdOpportunity mdo : opportunities.getOpportunities()){
                        if(mdo.getId().equals(opportunityId)){
                            mdOpportunity = mdo;
                            break;
                        }
                    }
                }
                hideProgressDialog();
                onComplete.run();
            }

            @Override
            public void onFailure(Call<BaseResponse<MdOpportunities>> call, Throwable t) {
                hideProgressDialog();
                onComplete.run();
            }
        });
    }

    private void initView() {
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        opportunityNo = (TextView) findViewById(R.id.opportunity_no);
        definition = (TextView) findViewById(R.id.definition);
        status = (TextView) findViewById(R.id.status);
        customer = (TextView) findViewById(R.id.customer);
        estimatedVal = (TextView) findViewById(R.id.estimated_val);
        salesOffice = (TextView) findViewById(R.id.sales_office);
        creationDate = (TextView) findViewById(R.id.creation_date);
        customerNo = (TextView) findViewById(R.id.customer_no);
        notes = (TextView) findViewById(R.id.notes);
        expectedEndDate = (TextView) findViewById(R.id.expected_end_date);
        maglev = (TextView) findViewById(R.id.maglev);
        relatedPerson = (TextView) findViewById(R.id.related_person);
        stage = (TextView) findViewById(R.id.stage);
        successChange = (TextView) findViewById(R.id.success_change);
        opportunityGroup = (TextView) findViewById(R.id.opportunity_group);
        source = (TextView) findViewById(R.id.source);
        priority = (TextView) findViewById(R.id.priority);
        pssr = (TextView) findViewById(R.id.pssr);
        operationallyResponsible = (TextView) findViewById(R.id.operationally_responsible);
        model = (TextView) findViewById(R.id.model);
        serialNumber = (TextView) findViewById(R.id.serial_number);
        createOfferBtn = findViewById(R.id.create_offer_btn);
        items_RV = findViewById(R.id.opportunity_items_rv); items_RV.setLayoutManager(new LinearLayoutManager(this));
        offers_RV =findViewById(R.id.opportunity_offers_rv); offers_RV.setLayoutManager(new LinearLayoutManager(this));
    }

    private void bindView() {
        if(mdOpportunity == null){
            return;
        }
        opportunityNo.setText(Utility.trimLeadingZeros(mdOpportunity.getId()));
        definition.setText(mdOpportunity.getDescription());
        status.setText(mdOpportunity.getStatus());
        customer.setText(mdOpportunity.getCustomer());
        estimatedVal.setText(Utility.getFormattedPrice(mdOpportunity.getExpectedRevenue().toString(),mdOpportunity.getCurrency()));
        salesOffice.setText(mdOpportunity.getSalesOffice());
        creationDate.setText(mdOpportunity.getStartDate());
        customerNo.setText(mdOpportunity.getCustomerNo());
        notes.setText(notesToString(mdOpportunity.getNotes()));

        expectedEndDate.setText(mdOpportunity.getExpectedEndDate());
        maglev.setText(mdOpportunity.getMaglevSegment());
        //relatedPerson.setText(mdOpportunity.getOperationalRespPerson());
        stage.setText(mdOpportunity.getOfferStage());
        successChange.setText(mdOpportunity.getSuccessChance());
        opportunityGroup.setText(mdOpportunity.getGroup());
        source.setText(mdOpportunity.getSource());
        priority.setText(mdOpportunity.getPriority());
        pssr.setText(mdOpportunity.getPssrName());
        operationallyResponsible.setText(mdOpportunity.getOperationalRespPerson());
        model.setText(mdOpportunity.getEquipmentModel());
        serialNumber.setText(mdOpportunity.getEquipmentSerialNo());
        if(mdOpportunity.getProducts() != null){
            productsAdapter = new OpportunityProductsAdapter(mdOpportunity.getProducts(), product -> {

            });
            items_RV.setAdapter(productsAdapter);
            productsAdapter.notifyDataSetChanged();
        }

        createOfferBtn.setOnClickListener(v -> createOffer());
    }

    public String notesToString(List<String> notes) {
        if (notes == null) {
            return "";
        }
        Iterator<String> iterator = notes.iterator();
        String result = "";
        while (iterator.hasNext()) {
            String row = iterator.next();
            result += row;
            if (iterator.hasNext()) {
                result += "\n";
            }
        }
        return result;
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

    public void createOffer(){
        CreateOfferRequestBody body = new CreateOfferRequestBody();
        List<Product> movedList =  productsAdapter.getMovedToOfferList();
        body.setDocumentReferenceNumber(mdOpportunity.getId());
        body.setDescription(mdOpportunity.getDescription());
        body.setCustomer(mdOpportunity.getCustomerNo());
        body.setCustomerAddress(mdOpportunity.getAddress().getId());
        //body.setSalesOffice(mdOpportunity.getSalesOffice()); value is required
        // body.setConnectedPerson(mdOpportunity.getContacts());
        body.setOrigin(mdOpportunity.getSource());
        //body.setPSSR
        // priority value is required
        body.setEquipment(mdOpportunity.getEquipmentSerialNo());
        for(Product p  : movedList){
            body.getItemList().add(OfferItem.create(p.getProductIdentifier(),p.getQuantity()));
        }

        Intent i = new Intent(this, CreateOfferActivity.class);
        i.putExtra("customerID", mdOpportunity.getCustomerNo());
        i.putExtra("customerName", mdOpportunity.getCustomer());
        i.putExtra("requestBody", body);
        startActivity(i);
    }
}
