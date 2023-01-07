package com.san.sniper.activities;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.san.sniper.AppConstants;
import com.san.sniper.adapters.customersearch.FilterableSearchTypeListAdapter;
import com.san.sniper.entity.RecentSearchEntity;
import com.san.sniper.enums.CustomerFilterType;
import com.san.sniper.enums.CustomerSearchType;
import com.san.sniper.requestpojos.CustomerSearchRequest;
import com.san.sniper.responsepojos.customer.EtIndustryCode;
import com.san.sniper.responsepojos.customer.EtPwc;
import com.san.sniper.responsepojos.customer.EtPwcResponse;
import com.san.sniper.singletons.SniperUser;
import com.san.sniper.views.FilterableSearchView;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.os.SystemClock;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.Toast;

import com.san.sniper.DataKeys;
import com.san.sniper.LogConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.interfaces.IsanServices;
import com.san.sniper.responsepojos.Equipment;
import com.san.sniper.responsepojos.Fields;
import com.san.sniper.responsepojos.customer.Address;
import com.san.sniper.responsepojos.response.CustomerResponse;
import com.san.sniper.responsepojos.response.EquipmentsResponse;
import com.san.sniper.service.BaseService;
import com.san.sniper.service.CustomerService;
import com.san.sniper.singletons.DataTransfer;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.toptoche.searchablespinnerlibrary.SearchableSpinner;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class UpdateEquipmentActivity extends BaseActivity implements FilterableSearchView.OnQueryTextListener, FilterableSearchTypeListAdapter.OnFilterTypeClickListener {

    ArrayList<String> parameters = new ArrayList<>();

    ProgressDialog dialog;
    HashMap<String, List<Fields.Values>> myMap = new HashMap<String, List<Fields.Values>>();
    EditText edtSerialNumber, edtManufactureYear, edtDisplayName, edtEngineModel, edtDueDate, edtArrangementNumber,
            edtTransactionStoreCode, edtWorkHour, edtEngineSerialNumber, edtReadingDate;

    SearchableSpinner spnrCustomer,spnrManufacture, spnrApplicationCode, spnrSection, spnrProductCode, spnrPWC, spnrengineProductCode, spnrTerritory, spnrAdress,
            snprIndustryCode;
    ImageView ivButtonFilterCustomers;
    String customerID;
    Equipment equipment;
    ArrayList<String> myAddress = new ArrayList<>();
    List<Address> addressList=new ArrayList<>();
    HashMap<String,String> values = new HashMap<>();
    FrameLayout contentCustomer;
    FloatingActionButton fab;
    Toolbar toolbar;
    private ProgressDialog progressDialog;
    CustomerService customerService = new CustomerService();
    BaseService baseService = new BaseService();
    List<EtIndustryCode> industryCodeList = new ArrayList<>();

    //Customer Search
    List<CustomerResponse.SingleCustomer> customers = new ArrayList<>();
    private FilterableSearchView filterableSearchView;
    SharedPreferences preferences;
    CustomerSearchRequest customerSearchRequest;
    CustomerSearchType selectedSearchType;
    CustomerResponse.SingleCustomer relatedCustomer;
    boolean isCrudAvailable;
    String accessUserData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_update_equipment);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        progressDialog = new ProgressDialog(UpdateEquipmentActivity.this);
        progressDialog.setMessage(getString(R.string.please_wait));
        preferences = getSharedPreferences("RunningAssistant.preferences", Context.MODE_PRIVATE);

        findByViews();
        dialog = new ProgressDialog(this);
        dialog.setMessage(getString(R.string.please_wait));

        Intent intent = getIntent();
        equipment = (Equipment) intent.getSerializableExtra("equipment");
        getSupportActionBar().setTitle(equipment.getDisplayModel() + "-" + equipment.getSerialNumber());
        addressList = (ArrayList<Address>) intent.getSerializableExtra("Addresses");
        addressList.add(0 ,null); // First empty
        for (int i = 0; i < addressList.size(); i++) {
            Address address = addressList.get(i);
            if(address != null){
                myAddress.add(address.getStreet()+" "+address.getDistrict() + " "+ address.getCity()+" "+address.getCountry());
            }else {
                myAddress.add("");
            }
        }

        customerID = intent.getStringExtra("customerID");
        accessUserData = intent.getStringExtra("accessUserData");
        isCrudAvailable = intent.getBooleanExtra("isCrudAvailable", false);
        fetchCustomers(); // it should be called after intent.getStringExtra("customerID")

        ArrayList<String> values = new ArrayList<>();
        values.add("I");
        values.add("O");
        populateSpinner(spnrTerritory, values);
        populateSpinner(spnrAdress, myAddress);
        setValues();
        //Counter
        parameters.add("Make");
        parameters.add("ApplicationCode");
        parameters.add("EMPC");
        //parameters.add("PWC");
        getLookUpsPWC(equipment.getR3ident());
        parameters.add("EMC");
        parameters.add("Division");

        for (int i = 0; i < parameters.size(); i++) {
            String key = parameters.get(i);
            getLookUps(key);

        }

        fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!isCrudAvailable) {
                    showCrudOperationInfoDialog();
                    return;
                }

                updateCustomerInfo();

            }
        });

        if(!isCrudAvailable) {
            fab.setAlpha(0.6f);
        }

        ScrollView sv = findViewById(R.id.scrollView);

        StringBuilder attachedInfoBuilder =  new StringBuilder();
        attachedInfoBuilder.append("Customer:").append(intent.getStringExtra("customerID")).append(", ")
                .append("Model:").append(equipment.getDisplayModel()).append(", ")
                .append("SerialNo:").append(equipment.getSerialNumber());
        Utility.logUsage(LogConstants.Section.CUSTOMER,LogConstants.Activity.OPEN_san_EQUIPMENT_DETAIL,attachedInfoBuilder.toString());

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) {
            finish();
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        if (contentCustomer.getVisibility()==View.VISIBLE){
            getSupportFragmentManager().popBackStack();
            contentCustomer.setVisibility(View.GONE);
        }else {
            super.onBackPressed();
        }
    }

    private void findByViews() {
        contentCustomer = (FrameLayout) findViewById(R.id.contentCustomer);
        spnrCustomer = findViewById(R.id.spnrCustomer);

        //prepare searchview
        filterableSearchView = findViewById(R.id.filterable_search_view);
        filterableSearchView.setOnFilterTypeClickListener(this);
        filterableSearchView.setOnQueryTextListener(this);
        filterableSearchView.setCustomerService(customerService);
        filterableSearchView.initFilters(CustomerFilterType.ONLY_CUSTOMER.getValue());
        filterableSearchView.setRecentSearchList(getRecentSearchList());
        selectedSearchType = CustomerSearchType.CUSTOMER_INFORMATION;

        edtSerialNumber = (EditText) findViewById(R.id.edtSerialNumber);disableView(edtSerialNumber);
        edtManufactureYear = (EditText) findViewById(R.id.edtManufactureYear);disableView(edtManufactureYear);
        edtDisplayName = (EditText) findViewById(R.id.edtDisplayName);disableView(edtDisplayName);
        edtEngineModel = (EditText) findViewById(R.id.edtEngineModel);disableView(edtEngineModel);
        edtDueDate = (EditText) findViewById(R.id.edtDueDate);disableView(edtDueDate);
        edtArrangementNumber = (EditText) findViewById(R.id.edtArrangementNumber);disableView(edtArrangementNumber);
        edtTransactionStoreCode = (EditText) findViewById(R.id.edtTransactionStoreCode);disableView(edtTransactionStoreCode);
        edtWorkHour = (EditText) findViewById(R.id.edtWorkHour);
        edtEngineSerialNumber = (EditText) findViewById(R.id.edtEngineSerialNumber);disableView(edtSerialNumber);
        edtReadingDate = findViewById(R.id.edt_reading_date);disableView(edtReadingDate);

        spnrManufacture = findViewById(R.id.spnrManufacture);disableView(spnrManufacture);
        spnrApplicationCode = findViewById(R.id.spnrApplicationCode);
        spnrSection = findViewById(R.id.spnrSection);disableView(spnrSection);
        spnrProductCode = findViewById(R.id.spnrProductCode);disableView(spnrProductCode);
        spnrPWC = findViewById(R.id.spnrPWC);
        snprIndustryCode = findViewById(R.id.spnrIndustryCode);
        spnrengineProductCode = findViewById(R.id.spnrengineProductCode);disableView(spnrengineProductCode);
        spnrTerritory = findViewById(R.id.spnrTerritory);disableView(spnrTerritory);
        spnrAdress = findViewById(R.id.spnrAdress);
        ivButtonFilterCustomers = findViewById(R.id.image_button_filter_customers);

        updateTextSearchableSpinner(spnrManufacture, spnrApplicationCode, spnrSection, spnrProductCode, spnrPWC, spnrengineProductCode, spnrTerritory, spnrAdress);
        spnrPWC.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String pwc = values.get(spnrPWC.getSelectedItem().toString());
                List<EtIndustryCode> filteredIndustryCodes = new ArrayList<>();
                for (EtIndustryCode ic : industryCodeList) {
                    if(ic.getPwc().equals(pwc)){
                        filteredIndustryCodes.add(ic);
                    }
                }
                ArrayAdapter<EtIndustryCode> icAdapter = new ArrayAdapter<>(UpdateEquipmentActivity.this, R.layout.spinner_item, filteredIndustryCodes);
                snprIndustryCode.setAdapter(icAdapter);
                icAdapter.notifyDataSetChanged();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        ivButtonFilterCustomers.setOnClickListener(v -> {
            filterableSearchView.updateRecentSearchList(getRecentSearchList());
            filterableSearchView.startSearcherAnimation();
        });
    }

    public void updateTextSearchableSpinner(SearchableSpinner... spinners){
        for (int i = 0; i<spinners.length;i++){
            spinners[i].setTitle("");
            spinners[i].setPositiveButton(getString(R.string.close_lbl));
        }
    }

    public void disableView(View view){
        if (view instanceof Spinner) {
            ((Spinner) view).setDropDownWidth(0);
            view.setAlpha(0.3f);
        }else{
            view.setAlpha(0.68f);
        }
        view.setEnabled(false);
        if (view instanceof ViewGroup) {
            ViewGroup viewGroup = (ViewGroup) view;
            for (int i = 0; i < viewGroup.getChildCount(); i++) {
                View child = viewGroup.getChildAt(i);
                disableView(child);
            }
        }
    }

    private void populateSpinner(Spinner spinner, ArrayList<String> list) {
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                R.layout.spinner_item, list);
        spinner.setAdapter(adapter);
    }

    private void setValues() {

        edtSerialNumber.setText(equipment.getSerialNumber());
        edtSerialNumber.setFocusable(false);

        edtManufactureYear.setText(equipment.getYearOfManufacture());
        edtManufactureYear.setFocusable(false);

        edtDisplayName.setText(equipment.getDisplayModel());
        edtEngineModel.setText(equipment.getEngineModel());
        edtDueDate.setText(equipment.getDueDate());
        edtArrangementNumber.setText(equipment.getArrangementNumber());
        edtTransactionStoreCode.setText(equipment.getTransactionStoreCode());
        edtWorkHour.setText(String.valueOf(equipment.getCounter()));
        edtEngineSerialNumber.setText(equipment.getEngineSerialNumber());
        edtReadingDate.setText(equipment.getReadingDate());

        if(equipment.getTerritory().equals("O")){
            spnrTerritory.setSelection(1);
        }else{
            spnrTerritory.setSelection(0);
        }

        int id  = 0;
        for (int i = 0 ; i<addressList.size();i++){
            Address address = addressList.get(i);
            if(address != null && Utility.trimLeadingZeros(address.getId()).equals(Utility.trimLeadingZeros(equipment.getAddressId()))){
                id= i;
                break;
            }
        }
        spnrAdress.setSelection(id);
    }

    public void updateCustomerInfo() {
        dialog.show();
        Gson gson = new Gson();
        String originalEquipment = gson.toJson(equipment);

        equipment.setArrangementNumber(edtArrangementNumber.getText().toString());
        equipment.setYearOfManufacture(edtManufactureYear.getText().toString());
        equipment.setDisplayModel(edtDisplayName.getText().toString());
        equipment.setEngineModel(edtEngineModel.getText().toString());
        equipment.setDueDate(edtDueDate.getText().toString());
        equipment.setTransactionStoreCode(edtTransactionStoreCode.getText().toString());

        if (edtWorkHour.getText().toString().length() > 0) {
            equipment.setCounter(edtWorkHour.getText().toString());
        }
        equipment.setEngineSerialNumber(edtEngineSerialNumber.getText().toString());
        equipment.setMake(getSpinnerValue("Make"));
        equipment.setApplicationCode(getSpinnerValue("ApplicationCode"));
        equipment.seteMPC(getSpinnerValue("EMPC"));
        equipment.setpWC(getSpinnerValue("PWC"));
        equipment.seteMC(getSpinnerValue("EMC"));
        equipment.setDivision(getSpinnerValue("Division"));
        equipment.setIndustryCode(getSpinnerValue("IC"));
        if(addressList.size()>0){
            Address currentAddress = addressList.get(spnrAdress.getSelectedItemPosition());
            if(currentAddress != null){
                equipment.setAddressId(addressList.get(spnrAdress.getSelectedItemPosition()).getId());
            }
        }

        String result = gson.toJson(equipment);
        if(originalEquipment.equals(result)){
            dialog.dismiss();
            onBackPressed();
        }else{
            JSONObject jsonObject = null;
            try {
                jsonObject = new JSONObject(result);
                jsonObject.put("CustomerId", customerID);
                Log.d(getLocalClassName(), jsonObject.toString());
            } catch (JSONException e) {
                Log.e("STACKTRACE",e.getMessage(),e);
            }


            Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
            IsanServices ibs = retrofit.create(IsanServices.class);
            Call<EquipmentsResponse> response = ibs.catEquipmentEdit(baseService.auth, baseService.username, jsonObject.toString());
            response.enqueue(new Callback<EquipmentsResponse>() {
                @Override
                public void onResponse(Call<EquipmentsResponse> call, Response<EquipmentsResponse> response) {
                    if (response.body()!= null && response.body().isSuccessful()) {

                        //Log equipmentUpdate
                        Utility.logUsage(LogConstants.Section.CUSTOMER,LogConstants.Activity.UPDATE_EQUIPMENT,
                                equipment.getName()+"/"+equipment.getSerialNumber());
                        dialog.dismiss();
                        Toast.makeText(getApplicationContext(), getString(R.string.update_successfully), Toast.LENGTH_LONG).show();
                        Intent returnIntent = new Intent();
                        setResult(Activity.RESULT_OK, returnIntent);
                        finish();
                    } else {
                        dialog.dismiss();
                        EquipmentsResponse equipmentsResponse = response.body();
                        if (equipmentsResponse != null &&  equipmentsResponse.getMessages() != null && !equipmentsResponse.getMessages().isEmpty()) {
                            String message = "";
                            for (String m : equipmentsResponse.getMessages()) {
                                message += m + "\n";
                            }
                            AlertDialog.Builder builder = new AlertDialog.Builder(UpdateEquipmentActivity.this);
                            builder.setTitle(R.string.new_service_demand_error)
                                    .setMessage(message)
                                    .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                        }
                                    })
                                    .show();
                        }
                    }
                }

                @Override
                public void onFailure(Call<EquipmentsResponse> call, Throwable t) {
                    dialog.dismiss();
                    Toast.makeText(getApplicationContext(), getString(R.string.update_not_successfully), Toast.LENGTH_LONG).show();

                }
            });

        }

    }

    private String getSpinnerValue(String type) {

        String value = "";
        if (type.equals("Make")) {
            value = values.get(spnrManufacture.getSelectedItem().toString());
        } else if (type.equals("ApplicationCode")) {
            value = values.get(spnrApplicationCode.getSelectedItem().toString());
        } else if (type.equals("EMPC")) {
            value = values.get(spnrengineProductCode.getSelectedItem().toString());
        } else if (type.equals("PWC")) {
            value = values.get(spnrPWC.getSelectedItem().toString());
        } else if (type.equals("EMC")) {
            if(spnrProductCode.getSelectedItem() == null){
                value = equipment.geteMPC();
            }else{
                value = values.get(spnrProductCode.getSelectedItem().toString());
            }
        } else if (type.equals("Division")) {
            value = values.get(spnrSection.getSelectedItem().toString());
        }
        else if (type.equals("IC")) {
            if(snprIndustryCode.getSelectedItem() instanceof Fields.Values){
                value = ((Fields.Values) snprIndustryCode.getSelectedItem()).getValue();

            }
        }

        return value;
    }

    public void prpAdapter(String type) {
        ArrayList<String> keys = new ArrayList<>();
        ArrayList<String> keyValues = new ArrayList<>();

        if("PWC".equals(type)){
            keys.add("-");
            keyValues.add("");
        }
        for (Fields.Values value : myMap.get(type)) {
            String key =value.getName() + " - " +value.getValue();
            keys.add(key);
            values.put(key,value.getValue());
            keyValues.add(value.getValue());

        }



        ArrayAdapter<String> adapter;
        if (!"PWC".equals(type)) {
            adapter = new ArrayAdapter<String>(this,
                    R.layout.spinner_item, keys);
        } else {
            //PWC!
            adapter = new ArrayAdapter<String>(this,
                    R.layout.spinner_item, keys);
        }

        //empc Equipment Manufacturing Product Code
        //pwc Principle Work Code of Equipment
        //emc Engine Manufacture Code

        if (type.equals("Make")) {

            spnrManufacture.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.getMake());
            spnrManufacture.setSelection(index);

        } else if (type.equals("ApplicationCode")) {
            spnrApplicationCode.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.getApplicationCode());
            spnrApplicationCode.setSelection(index);
        } else if (type.equals("EMPC")) {
            spnrengineProductCode.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.geteMPC());
            spnrengineProductCode.setSelection(index);
        } else if (type.equals("PWC")) {
            spnrPWC.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.getpWC());
            spnrPWC.setSelection(index);

        } else if (type.equals("EMC")) {
            spnrProductCode.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.geteMC());
            spnrProductCode.setSelection(index);
            adapter.notifyDataSetChanged();
            spnrProductCode.invalidate();
        } else if (type.equals("Division")) {
            spnrSection.setAdapter(adapter);
            int index = keyValues.indexOf(equipment.getDivision());
            spnrSection.setSelection(index);
        }
    }

    public void getLookUpsPWC(String r3Ident){
        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);

        Call<EtPwcResponse> responseCall = ibs.equipmentIndustryCode(baseService.auth, r3Ident);
        responseCall.enqueue(new Callback<EtPwcResponse>() {
            @Override
            public void onResponse(Call<EtPwcResponse> call, Response<EtPwcResponse> response) {
                if (response.body() != null && response.body().isSuccessful()) {
                    List<EtPwc> etPwcList = response.body().getData().getEtPwc();
                    List<EtIndustryCode> etIndustryCodesList = response.body().getData().getEtIndustryCode();
                    List<Fields.Values> mValues = new ArrayList<>();

                    if(etPwcList != null && !etPwcList.isEmpty()){
                        for (EtPwc etPwc : etPwcList) {
                            mValues.add(Fields.createValue(etPwc.getPwcDesc(),etPwc.getPwc()));
                        }
                    }

                    myMap.put("PWC", mValues);
                    prpAdapter("PWC");

                    industryCodeList = etIndustryCodesList;

                }else{
                    Toast.makeText(getApplicationContext(),R.string.new_service_demand_error,Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<EtPwcResponse> call, Throwable t) {
                Log.e(getCallingPackage(), t.getLocalizedMessage());
            }
        });
    }

    public void getLookUps(final String value) {
        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);

        Call<Fields> responseCall = ibs.updateFields(baseService.auth, baseService.username, value);
        responseCall.enqueue(new Callback<Fields>() {
            @Override
            public void onResponse(Call<Fields> call, Response<Fields> response) {
                if (response.body() != null && response.body().isSuccessful()) {
                    List<Fields.Values> mValues = response.body().getData().getValues();
                    myMap.put(value, mValues);
                    prpAdapter(value);
                }else{
                    Toast.makeText(getApplicationContext(),R.string.new_service_demand_error,Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<Fields> call, Throwable t) {
                Log.e(getCallingPackage(), t.getLocalizedMessage());
            }
        });
    }

    private void fetchCustomers() {
        customers = DataTransfer.getInstance().getData(DataKeys.CUSTOMER_LIST, List.class);
        if(customers != null){
            customersOnReady(customers);
            return;
        }

        progressDialog.show();
        customerSearchRequest = new CustomerSearchRequest();
        customerSearchRequest.setUserName(SniperUser.getInstance().username);

        customerService.searchCustomers(customerSearchRequest, true, (result,t) -> {
            if(result != null){
                customers = result;
                customersOnReady(result);
            }
            progressDialog.dismiss();
        });
    }

    public void searchCustomers() {
        progressDialog.show();
        customerService.searchCustomers(customerSearchRequest, false, (result,t) -> {
            if(result != null){
                customers = result;
                customersOnReady(result);
            }
            progressDialog.dismiss();
            touchSpinner(spnrCustomer);
        });
    }

    public void touchSpinner(View view) {
        long downTime = SystemClock.uptimeMillis();
        long eventTime = SystemClock.uptimeMillis() + 100;
        float x = 0.0f;
        float y = 0.0f;

        int metaState = 0;
        MotionEvent motionEvent = MotionEvent.obtain(downTime, eventTime, MotionEvent.ACTION_UP, x, y, metaState);

        view.dispatchTouchEvent(motionEvent);
    }

    public void customersOnReady(List<CustomerResponse.SingleCustomer> customerList){
        final ArrayList<String> nameList = new ArrayList<>();
        final ArrayList<String> valueList = new ArrayList<>();
        nameList.add("");
        valueList.add("");
        for (CustomerResponse.SingleCustomer cm : customerList) {
            valueList.add(cm.getId());
            nameList.add(cm.getName()+" / " + Utility.trimLeadingZeros(cm.getId()));
        }
        final ArrayAdapter<String> adapter = new ArrayAdapter<String>(UpdateEquipmentActivity.this,
                R.layout.list_items_layout, nameList);

        spnrCustomer.setAdapter(adapter);
        if(customerID != null){
            int position = valueList.indexOf(customerID);
            spnrCustomer.setSelection(position);
        }
        spnrCustomer.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(position != 0) {
                    customerID = valueList.get(position);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    @Override
    public void onFilterTypeClick(CustomerSearchType searchType) {
        if(selectedSearchType == CustomerSearchType.USERNAME && searchType != CustomerSearchType.USERNAME) {
            showKeyboard(this);
        }
        selectedSearchType = searchType;
    }

    @Override
    public boolean onQueryTextSubmit(String query) {
        filterableSearchView.setVisibility(View.INVISIBLE);
        if(!query.isEmpty() && selectedSearchType == null) {
            Toast.makeText(this, getString(R.string.customer_search_select_a_type_message), Toast.LENGTH_SHORT).show();
        }

        if(!query.isEmpty() && selectedSearchType != null) {
            prepareSearchDto(query.toUpperCase());
            checkIfSaveNeededRecentSearch(selectedSearchType, query);
            searchCustomers();
        }
        return false;
    }

    @Override
    public boolean onQueryTextChange(String newText) {
        return false;
    }

    @Override
    public void onSearchResetClicked() {
        customers = DataTransfer.getInstance().getData(DataKeys.CUSTOMER_LIST, List.class);
        if(customers != null) {
            filterableSearchView.setVisibility(View.INVISIBLE);
            customersOnReady(customers);
            touchSpinner(spnrCustomer);
            return;
        }
        filterableSearchView.setVisibility(View.INVISIBLE);
        customerSearchRequest = new CustomerSearchRequest();
        customerSearchRequest.setUserName(SniperUser.getInstance().username);
        searchCustomers();
    }

    @Override
    public void onResetHistoryClicked() {
        String recentSearchListObj = new Gson().toJson(new ArrayList<>());
        preferences.edit().putString(AppConstants.CUSTOMER_RECENT_SEARCHES_KEY, recentSearchListObj).apply();
        filterableSearchView.updateRecentSearchList(new ArrayList<>());
    }

    public void checkIfSaveNeededRecentSearch(CustomerSearchType searchType, String query) {
        RecentSearchEntity recentSearchEntity = new RecentSearchEntity(searchType.getValue(), query);
        String recentSearchObj = preferences.getString(AppConstants.CUSTOMER_RECENT_SEARCHES_KEY, null);

        if(recentSearchObj != null) {
            ArrayList<RecentSearchEntity> recentSearchEntities = new Gson().fromJson(recentSearchObj, new TypeToken<List<RecentSearchEntity>>(){}.getType());
            if(recentSearchEntities != null) {
                RecentSearchEntity checkIfAddedBefore = recentSearchEntities.stream()
                        .filter(entity -> recentSearchEntity.getQuery().equals(entity.getQuery()) && recentSearchEntity.getSearchType().equals(entity.getSearchType()))
                        .findAny()
                        .orElse(null);

                if(checkIfAddedBefore == null) {
                    saveRecentSearch(recentSearchEntities, recentSearchEntity);
                }
            }
        } else {
            saveRecentSearch(new ArrayList<>(), recentSearchEntity);
        }
    }

    public void saveRecentSearch(ArrayList<RecentSearchEntity> recentSearchList, RecentSearchEntity saveData) {
        recentSearchList.add(saveData);
        String recentSearchListObj = new Gson().toJson(recentSearchList);
        preferences.edit().putString(AppConstants.CUSTOMER_RECENT_SEARCHES_KEY, recentSearchListObj).apply();
    }

    public ArrayList<RecentSearchEntity> getRecentSearchList() {
        String recentSearchesObj = preferences.getString(AppConstants.CUSTOMER_RECENT_SEARCHES_KEY, null);
        if(recentSearchesObj != null) {
            ArrayList<RecentSearchEntity> recentSearchEntities = new Gson().fromJson(recentSearchesObj, new TypeToken<List<RecentSearchEntity>>(){}.getType());
            if(recentSearchEntities != null) {
                List<RecentSearchEntity> filteredRecentActivityList = recentSearchEntities.stream().filter(entity -> entity.getSearchType().equals(CustomerSearchType.CUSTOMER_INFORMATION.getValue()))
                        .collect(Collectors.toList());
                Collections.reverse(filteredRecentActivityList);
                return new ArrayList<>(filteredRecentActivityList);
            }
        }
        return new ArrayList<>();
    }

    private void prepareSearchDto(String query) {
        customerSearchRequest = new CustomerSearchRequest();
        if(selectedSearchType == CustomerSearchType.CUSTOMER_INFORMATION) {
            customerSearchRequest.setCustomer(query);
        } else if(selectedSearchType == CustomerSearchType.USERNAME) {
            customerSearchRequest.setUserName(query);
        } else if(selectedSearchType == CustomerSearchType.EQUIPMENT_NO) {
            customerSearchRequest.setEquipmentSerialNo(query);
        } else if(selectedSearchType == CustomerSearchType.DOCUMENT_NUMBER) {
            customerSearchRequest.setDocumentNumber(query);
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
