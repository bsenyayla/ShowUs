package com.borusan.sniper.activities;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;

import com.borusan.sniper.fragments.SparePartOrderFragment;
import com.borusan.sniper.responsepojos.checkin.KeyValuePair;
import com.borusan.sniper.views.SalesmanBottomDialog;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.tabs.TabLayout;

import androidx.san.widget.san;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;

import android.text.Html;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.UnderlineSpan;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.borusan.sniper.AppConstants;
import com.borusan.sniper.CityList;
import com.borusan.sniper.DataKeys;
import com.borusan.sniper.LogConstants;
import com.borusan.sniper.R;
import com.borusan.sniper.Utility;
import com.borusan.sniper.adapters.CustomerAdressAdapter;
import com.borusan.sniper.builders.RetrofitBuilder;
import com.borusan.sniper.fragments.CustomerDetailFragment;
import com.borusan.sniper.interfaces.IBorusanServices;
import com.borusan.sniper.responsepojos.customer.Address;
import com.borusan.sniper.responsepojos.customer.CustomerDetailModel;
import com.borusan.sniper.responsepojos.customer.Refraction;
import com.borusan.sniper.responsepojos.response.CustomerDetailResponse;
import com.borusan.sniper.responsepojos.response.CustomerResponse;
import com.borusan.sniper.service.BaseService;
import com.borusan.sniper.singletons.DataTransfer;
import com.borusan.sniper.singletons.SniperUser;

import java.sql.Array;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class CustomerDetailActivity extends BaseActivity implements
        CustomerDetailFragment.onSomeEventListener, CustomerDetailFragment.onCollapseEventListener,
        CustomerAdressAdapter.OnItemClick, SalesmanBottomDialog.SalesmanBottomDialogOutput {
    private TabLayout tabLayout;
    private ViewPager viewPager;

    private int[] customerDetailTabIds = new int[]{
            R.string.customer_detail_equipment,
            R.string.competitor_detail_compatitor,
            R.string.customer_detail_complaint,
            R.string.customer_detail_offer_run,
            R.string.customer_detail_opportunity_run,
            R.string.customer_detail_offer_md,
            R.string.customer_detail_opportunity_md,
            R.string.customer_detail_relatedperson,
            R.string.customer_detail_openworkorders,
            //R.string.customer_detail_sim_approvals,
            R.string.customer_detail_financialstatus,
            R.string.customer_detail_bank_accounts,
            R.string.customer_detail_part_orders
    };
    private Retrofit retrofit;
    CustomerResponse.SingleCustomer customer;
    ProgressBar mProgressBar;
    RecyclerView myRecycleView;
    CustomerDetailModel customerDetail;
    LinearLayout topContent, AdressContent;
    san secondContainer;
    LinearLayout salesRelations;
    TextView tvSalesRelations;
    SalesmanBottomDialog salesmanActionDialog;

    Button btnAddNewAdress;
    boolean isCollapsed = true;
    public boolean isCrudAvailable = false;
    public String accessUserData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_customer_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        myRecycleView = (RecyclerView) findViewById(R.id.myRecycleView);
        myRecycleView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
        mProgressBar = (ProgressBar) findViewById(R.id.mProgressBar);
        retrofit = RetrofitBuilder.getRetrofit(this.getApplication());
        viewPager = (ViewPager) findViewById(R.id.viewpager);
        tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(viewPager);
        topContent = findViewById(R.id.topContent);
        secondContainer = findViewById(R.id.secondContainer);
        AdressContent = findViewById(R.id.AdressContent);
        salesRelations = findViewById(R.id.salesRelations);;
        tvSalesRelations = findViewById(R.id.tvSalesRelations);

        customer = (CustomerResponse.SingleCustomer) getIntent().getSerializableExtra("customerobj");
        String trimmedZeros = Utility.trimLeadingZeros(customer.getCustomerId());
        setTitle(trimmedZeros + " - " + customer.getName());

        btnAddNewAdress = findViewById(R.id.btnAddNewAdress);
        if (SniperUser.getInstance().permissions.contains(AppConstants.User.Permission.CUSTOMER_ADDRESS_EDIT)) {
            btnAddNewAdress.setVisibility(View.VISIBLE);
        } else {
            btnAddNewAdress.setVisibility(View.GONE);
        }

        if(customer.relations != null) {
            String sapUsername = SniperUser.getInstance().username;
            customer.relations.stream()
                    .filter(relation -> sapUsername.equals(relation.username))
                    .findAny().ifPresent(checkIfCrudAvailable -> isCrudAvailable = true);

            if(!isCrudAvailable) {
                btnAddNewAdress.setAlpha(0.5f);
            }

            SpannableStringBuilder accessUserList = new SpannableStringBuilder();
            int relationCount = 0;

            for (CustomerResponse.CustomerRelation customerRelation : customer.getRelations()){
                if(accessUserList.length() > 0){
                    accessUserList.append(" ");
                }
                relationCount += 1;
                String relationString = relationCount + "." + customerRelation.partnerName + " ";
                accessUserList.append(relationString);

                ClickableSpan relationPartnerClickEvent = new ClickableSpan() {
                    @Override
                    public void onClick(View widget) {
                        openSalesmanActionDialog(customerRelation);
                    }
                    @Override
                    public void updateDrawState(TextPaint ds) {
                        super.updateDrawState(ds);
                        ds.setUnderlineText(true);
                        ds.setColor(tvSalesRelations.getContext().getColor(R.color.link_color));
                    }
                };

                int start = accessUserList.toString().length() - relationString.length();
                accessUserList.setSpan(relationPartnerClickEvent, start, accessUserList.toString().length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            accessUserData = accessUserList.toString();

            if(!accessUserData.isEmpty()) {
                salesRelations.setVisibility(View.VISIBLE);
                tvSalesRelations.setText(accessUserList, TextView.BufferType.SPANNABLE);
                tvSalesRelations.setMovementMethod(LinkMovementMethod.getInstance());
                tvSalesRelations.setHighlightColor(Color.TRANSPARENT);
            }
        }

        requestForCustomerDetail(0, false);
    }

    private void openSalesmanActionDialog(CustomerResponse.CustomerRelation customerRelation) {
        if(salesmanActionDialog == null) {
            salesmanActionDialog = new SalesmanBottomDialog(this);
        }

        salesmanActionDialog.setSalesman(customerRelation);
        salesmanActionDialog.show(getSupportFragmentManager(), "salesmanBottomDialog");
    }

    @Override
    public void onActionItemClicked(int type, int position, String value) {
        salesmanActionDialog.dismiss();
        if(type == 1) {
            try {
                Intent callIntent = new Intent(Intent.ACTION_DIAL);
                callIntent.setData(Uri.parse("tel:" + value));
                startActivity(callIntent);
            } catch (android.content.ActivityNotFoundException ex) {
                Toast.makeText(this, getString(R.string.inbox_error), Toast.LENGTH_LONG).show();
            }
        } else if(type == 2) {
            Intent intent = new Intent(Intent.ACTION_SENDTO);
            intent.putExtra(Intent.EXTRA_SUBJECT, "");
            intent.putExtra(Intent.EXTRA_TEXT, "");
            intent.setData(Uri.parse("mailto:" + value));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        } else {
            Intent sendIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("msteams://teams.microsoft.com/l/chat/0/0?users=" + value));
            if (sendIntent.resolveActivity(getPackageManager()) != null) {
                startActivity(sendIntent);
            } else {
                final String appPackageName = "com.microsoft.teams";
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
                } catch (android.content.ActivityNotFoundException ex) {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)));
                }
            }
        }
    }

    public void collapsedController() {
        if (isCollapsed) {
            secondContainer.setVisibility(View.GONE);
            topContent.setVisibility(View.GONE);
            AdressContent.setVisibility(View.GONE);
        } else {
            secondContainer.setVisibility(View.VISIBLE);
            topContent.setVisibility(View.VISIBLE);
            AdressContent.setVisibility(View.VISIBLE);

        }
        isCollapsed = !isCollapsed;
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

    public void addNewAdress(View view) {
        if(!isCrudAvailable) {
            showCrudOperationInfoDialog();
            return;
        }

        Intent i = new Intent(this, CustomerAdressMapsActivity.class);
        i.putExtra("customerName", customer.getName());
        i.putExtra("customerID", customer.getCustomerId());
        i.putExtra("openAddressPicker", true);
        i.putExtra("isCrudAvailable", isCrudAvailable);
        startActivityForResult(i, Utility.RESPONSE_CODE_ADRESS);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            fragment.onActivityResult(requestCode, resultCode, data);
        }
        if (requestCode == Utility.RESPONSE_CODE_EQUIPMENTS) {
            if (resultCode == Activity.RESULT_OK) {
                requestForCustomerDetail(tabLayout.getSelectedTabPosition(), true);
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                //Write your code if there's no result
            }
        } else if (requestCode == Utility.RESPONSE_CODE_ADRESS) {
            if (resultCode == Activity.RESULT_OK) {
                requestForCustomerDetail(tabLayout.getSelectedTabPosition(), true);
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                //Write your code if there's no result
            }
        }else if (requestCode == Utility.RESPONSE_CODE_GENERAL) {
            if (resultCode == Activity.RESULT_OK) {
                requestForCustomerDetail(tabLayout.getSelectedTabPosition(), true);
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                //Write your code if there's no result
            }
        }
    }

    public void requestForCustomerDetail(final int selectedTab, final boolean refresh) {
        mProgressBar.setVisibility(View.VISIBLE);
        String lang = Locale.getDefault().getLanguage();
        IBorusanServices ibs = retrofit.create(IBorusanServices.class);
        BaseService baseService = new BaseService();
        final Call<CustomerDetailResponse> customerDetailCall =
                ibs.customerDetails(baseService.auth, baseService.username, lang, customer.getCustomerId()); // Default

        customerDetailCall.enqueue(new Callback<CustomerDetailResponse>() {
            @Override
            public void onResponse(Call<CustomerDetailResponse> call, Response<CustomerDetailResponse> response) {
                if (response.body() != null && response.body().getData() != null && response.body().isSuccessful()) {
                    //Gson gson = new Gson();
                    //String result = gson.toJson(response.body());
                    customerDetail = response.body().getData();
                    if (!refresh) {
                        setupViewPager(viewPager);
                    } else {
                        refreshFragment(selectedTab);
                    }


                    if (customerDetail.getContacts() != null) {
                        Collections.sort(customerDetail.getContacts(), (o1, o2) -> {
                            try {
                                Long id1 = Long.parseLong(o1.getPartnerNo());
                                Long id2 = Long.parseLong(o2.getPartnerNo());
                                return id1.compareTo(id2);
                            } catch (Exception e) {
                                return 0;
                            }
                        });
                        Collections.reverse(customerDetail.getContacts());
                    }

                    if (customerDetail.getMdOffers() != null) {
                        Collections.sort(customerDetail.getMdOffers(),(o1, o2) ->{
                            try{
                                Integer i1 = Integer.parseInt(o1.getObjectId());
                                Integer i2 = Integer.parseInt(o2.getObjectId());
                                return i1.compareTo(i2);
                            }catch (Exception e){
                                return 0;
                            }
                        });
                        Collections.reverse(customerDetail.getMdOffers());
                    }

                    List<Address> addressList = customerDetail.getAddresses();
                    List<String> sectorList = customerDetail.getSectors();
                    List<Refraction> refractionList = customerDetail.getRefractions();

                    StringBuilder sectorbuilder = new StringBuilder();
                    for (int i = 0; i < sectorList.size(); i++) {
                        String sector = sectorList.get(i);
                        sectorbuilder.append(sector);
                    }

                    ((TextView) findViewById(R.id.txtSectors)).setText(sectorbuilder.toString());

                    for (Address customerAdress : addressList) {
                        if (customerAdress.getIsBillAddress()) {
                            String city = CityList.getInstance().getCityByCode(customerAdress.getCityCode());
                            String adress = customerAdress.getStreet() + " " + customerAdress.getDistrict() + " " + customerAdress.getCity();
                            ((TextView) findViewById(R.id.txtBillingAdress)).setText(city + " - " + adress.trim());
                        }
                    }

                    StringBuilder refractionbuilder = new StringBuilder();
                    for (Refraction refraction : refractionList) {
                        refractionbuilder.append(refraction.getDescription());
                    }
                    ((TextView) findViewById(R.id.txtMaglev)).setText(refractionbuilder.toString());


                    CustomerAdressAdapter adressAdapter = new CustomerAdressAdapter(customerDetail.getAddresses(), CustomerDetailActivity.this);
                    myRecycleView.setAdapter(adressAdapter);
                    adressAdapter.notifyDataSetChanged();

                    mProgressBar.setVisibility(View.GONE);
                    tabLayout.setVisibility(View.VISIBLE);
                    viewPager.setVisibility(View.VISIBLE);

                    Utility.logUsage(LogConstants.Section.CUSTOMER, LogConstants.Activity.OPEN_CUSTOMER_DETAIL, customer.getCustomerId());
                } else {
                    mProgressBar.setVisibility(View.GONE);
                    if(response.body() != null){
                        showErrorDialog(response.body().messagesToString());
                    }else{
                        showErrorDialog(response.message());
                    }
                }
            }

            @Override
            public void onFailure(Call<CustomerDetailResponse> call, Throwable t) {
                //getDetailOfTab(0);
                mProgressBar.setVisibility(View.GONE);
                showErrorDialog(getString(R.string.new_service_demand_error));
            }
        });
    }

    public void showErrorDialog(String message) {
        try {
            if(isFinishing()){
                AlertDialog.Builder builder = new AlertDialog.Builder(CustomerDetailActivity.this);
                builder.setTitle(R.string.new_service_demand_error)
                        .setMessage(message)
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int id) {
                                onBackPressed();
                            }
                        })
                        .show();
            }
        }catch (Exception e){
            Log.e("CustomerDetailActivity",e.getMessage(),e);
        }

    }

    private void getDetailOfTab(final int positionTab) {
        requestForCustomerDetail(positionTab, true);
        //CustomerDetailFragment cdf = (CustomerDetailFragment) ((ViewPagerAdapter) viewPager.getAdapter()).getItem(positionTab);
        //cdf.populateData(positionTab,customerDetail);
    }

    ViewPagerAdapter fragmentsAdapter;

    private void setupViewPager(ViewPager viewPager) {
        fragmentsAdapter = new ViewPagerAdapter(getSupportFragmentManager());
        DataTransfer.getInstance().putData(DataKeys.LATEST_SELECTED_CUSTOMER, customer);
        for (int i = 0; i < customerDetailTabIds.length; i++) {
            int id = customerDetailTabIds[i];
            if (!SniperUser.isCanSeeServiceRequestApprovalSection() && id == R.string.customer_detail_sim_approvals)
                continue;
            if(id == R.string.customer_detail_part_orders){
                fragmentsAdapter.addFragment(SparePartOrderFragment.newInstance(), id);
            }else{
                fragmentsAdapter.addFragment(CustomerDetailFragment.newInstance(id, customer.getCustomerId(),customer.getName(), customerDetail, accessUserData), id);
            }
        }
        viewPager.setAdapter(fragmentsAdapter);
        fragmentsAdapter.notifyDataSetChanged();

    }

    public void refreshFragment(int position) {
        for (Fragment fragment : fragmentsAdapter.mFragmentList) {
            if (fragment instanceof CustomerDetailFragment) {
                CustomerDetailFragment cdf = (CustomerDetailFragment) fragment;
                cdf.setCustomerDetailModel(customerDetail);
            }
        }
        Fragment fragment =fragmentsAdapter.getItem(position);
        if(fragment instanceof CustomerDetailFragment){
            CustomerDetailFragment cdf = (CustomerDetailFragment) fragment;
            int id = fragmentsAdapter.getViewId(position);
            cdf.populateData(id, customerDetail);
        }
    }

    @Override
    public void someEvent(String s) {
        requestForCustomerDetail(tabLayout.getSelectedTabPosition(), true);
    }

    @Override
    public void onItemClicked(Address address) {
        Intent i = new Intent(this, CustomerAdressMapsActivity.class);
        i.putExtra("customerName", customer.getName());
        i.putExtra("customerAdress", address);
        i.putExtra("isCrudAvailable", isCrudAvailable);
        startActivityForResult(i, Utility.RESPONSE_CODE_ADRESS);
    }

    @Override
    public void onCollapsed() {
        collapsedController();
    }

    class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();
        private final List<Integer> mFragmentIdList = new ArrayList<>();

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

        public void addFragment(Fragment fragment, int id) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(getString(id));
            mFragmentIdList.add(id);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }

        public int getViewId(int position) {
            return mFragmentIdList.get(position);
        }
    }

    public void showCrudOperationInfoDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        String accessErrorMessage = getString(R.string.customer_detail_crud_operation_message) + "\n\n" + accessUserData;
        builder.setTitle(getString(R.string.customer_detail_crud_operation_title))
                .setMessage(accessErrorMessage)
                .show();
    }
}
