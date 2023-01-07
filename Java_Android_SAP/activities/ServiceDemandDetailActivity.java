package com.san.sniper.activities;

import android.app.DatePickerDialog;
import android.content.Context;
import android.content.Intent;
import androidx.databinding.DataBindingUtil;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import com.san.sniper.AppDatabase;
import com.san.sniper.DBAsyncTask;
import com.san.sniper.R;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.databinding.ActivityServiceDemandDetailBinding;
import com.san.sniper.requestpojos.AddServiceDemandRequest;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.ServiceDemandDetailResponse;
import com.san.sniper.responsepojos.ServiceDemands;
import com.san.sniper.responsepojos.response.NameValueResponse;
import com.san.sniper.searchableuifields.CategoryUIField;
import com.san.sniper.searchableuifields.ContactPersonUIField;
import com.san.sniper.searchableuifields.CustomerUIField;
import com.san.sniper.searchableuifields.SalesOfficeUIField;
import com.san.sniper.searchableuifields.SearchableUIField;
import com.san.sniper.searchableuifields.ServiceRepresentativeUIField;
import com.san.sniper.searchableuifields.StatusUIField;
import com.san.sniper.searchableuifields.UIFieldDependency;
import com.san.sniper.service.BaseService;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import ir.mirrajabi.searchdialog.core.BaseSearchDialogCompat;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ServiceDemandDetailActivity extends BaseActivity {


    private static final String BUNDLE_DEMANDID = "BUNDLE_DEMANDID";
    private static final String BUNDLE_USERNAME = "BUNDLE_USERNAME";
    private static final String BUNDLE_EDITABLE = "BUNDLE_EDITABLE";
    private static final String BUNDLE_DEMAND = "BUNDLE_DEMAND";

    private ActivityServiceDemandDetailBinding binding;
    private AddServiceDemandRequest addServiceDemandRequest = new AddServiceDemandRequest();

    BaseService baseService = new BaseService();


    private Map<Class<? extends SearchableUIField>, SearchableUIField> searchableUIFieldMap = new HashMap<>();

    public static void startActivity(Context context, String username, String demandId, boolean isEditable) {
        Intent intent = new Intent(context, ServiceDemandDetailActivity.class);
        intent.putExtra(BUNDLE_USERNAME, username);
        intent.putExtra(BUNDLE_DEMANDID, demandId);
        intent.putExtra(BUNDLE_EDITABLE, isEditable);
        context.startActivity(intent);
    }

    public static void startDraftedServiceDemandActivity(Context context, String username, ServiceDemands.Demand demand) {
        Intent intent = new Intent(context, ServiceDemandDetailActivity.class);
        intent.putExtra(BUNDLE_USERNAME, username);
        intent.putExtra(BUNDLE_DEMAND, demand);
        intent.putExtra(BUNDLE_EDITABLE, true);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = DataBindingUtil.setContentView(this, R.layout.activity_service_demand_detail);
        setSupportActionBar(binding.toolbar);
        setInitialBindings();
        fillUI();
        initializeSearchableUIFields();
        initializeClickListeners();
        setDetailTitle();
        initializeNavigationBack();
    }

    private void fillUI() {
        if (isServiceDemandDetail()) {
            fetchServiceDemandDetail();
        } else if (isServiceDemandDraft()) {
            setServiceDemandBinding(getServiceDemandFromIntent());
            initializeAddRequest();
        }
    }

    private void initializeAddRequest() {
        ServiceDemands.Demand serviceDemandFromIntent = getServiceDemandFromIntent();
        AddServiceDemandRequest addRequest = getServiceDemandFromUI();
        addRequest.setCategory(serviceDemandFromIntent.getCategoryId());
        addRequest.setContactPerson(serviceDemandFromIntent.getContactPersonNo());
        addRequest.setResponsiblePersonel(serviceDemandFromIntent.getResponsiblePersonelNo());
        addRequest.setStatus(serviceDemandFromIntent.getStatusId());
        addRequest.setSalesOffice(serviceDemandFromIntent.getSalesOfficeNo());
        addRequest.setCustomerId(serviceDemandFromIntent.getCustomerNo());
    }

    private void initializeSearchableUIFields() {
        SearchableUIField categoryUIField = new CategoryUIField();
        searchableUIFieldMap.put(CategoryUIField.class, categoryUIField);

        SearchableUIField customerUIField = new CustomerUIField();
        searchableUIFieldMap.put(CustomerUIField.class, customerUIField);

        SearchableUIField statusUIField = new StatusUIField();
        searchableUIFieldMap.put(StatusUIField.class, statusUIField);

        SearchableUIField salesOfficeUIField = new SalesOfficeUIField();
        searchableUIFieldMap.put(SalesOfficeUIField.class, salesOfficeUIField);

        SearchableUIField serviceRepresentativeUIField = new ServiceRepresentativeUIField();
        searchableUIFieldMap.put(ServiceRepresentativeUIField.class, serviceRepresentativeUIField);

        SearchableUIField contactPersonUIField = new ContactPersonUIField();
        searchableUIFieldMap.put(ContactPersonUIField.class, contactPersonUIField);


        contactPersonUIField.depends(
                new UIFieldDependency("customerId", getString(R.string.must_select_client),
                        binding.tvClient::getText, addServiceDemandRequest::getCustomerId)
        );

        serviceRepresentativeUIField.depends(
                new UIFieldDependency("salesOffice", getString(R.string.must_select_sales_office), binding.tvSalesOffice::getText,
                        addServiceDemandRequest::getSalesOffice),
                new UIFieldDependency("category", getString(R.string.must_select_category), binding.tvCategory::getText,
                        addServiceDemandRequest::getCategory)
        );
    }

    private void initializeNavigationBack() {
        binding.toolbar.setNavigationOnClickListener(this::onNavigationClick);
    }

    private void onNavigationClick(View view) {
        onBackPressed();
    }

    @Override
    public void onBackPressed() {
        if (isNewServiceDemand()) {
            persistServiceDemandAsDraft();
        }
        super.onBackPressed();
    }

    @SuppressWarnings("unchecked")
    private void persistServiceDemandAsDraft() {
        AppDatabase database = getDatabase();
        DBAsyncTask<Void> saveTask = new DBAsyncTask<>();
        saveTask.executeOnExecutor(database.getExecutorService(), () -> {
                    database.
                            getServiceDemandDao().insert(getServiceDemandFromUI().toEntity());
                    return null;
                }
        );
        addAsyncTask(saveTask);
    }

    private void setDetailTitle() {
        String title = getDetailTitle();
        setTitle(title);
        binding.toolbar.setTitle(title);
    }

    private String getDetailTitle() {
        return isEditable() ? getString(R.string.add_new_service_demand) : getString(R.string.service_demand_detail);
    }

    private void initializeClickListeners() {
        binding.fabAdd.setOnClickListener(this::onSaveServiceDemandClick);

        binding.tvClient.setOnClickListener(v -> getSearchableUIField(CustomerUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onClientItemSelected));
        binding.tvCategory.setOnClickListener(v -> getSearchableUIField(CategoryUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onCategoriesItemSelected));
        binding.tvActiveState.setOnClickListener(v -> getSearchableUIField(StatusUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onActiveStatusItemSelected));
        binding.tvSalesOffice.setOnClickListener(v -> getSearchableUIField(SalesOfficeUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onSalesOfficeItemSelected));
        binding.tvResponsiblePersonal.setOnClickListener(v -> getSearchableUIField(ServiceRepresentativeUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onServiceRepresantiveSelected));
        binding.etClientContact.setOnClickListener(v -> getSearchableUIField(ContactPersonUIField.class)
                .onClick(ServiceDemandDetailActivity.this, this::onClientContactPersonSelected));

        binding.tvTargetDate.setOnClickListener(this::onTargetDateClicked);
    }

    public void onTargetDateClicked(View view) {
        openTargetDateDialog();
    }

    private void openTargetDateDialog() {

        Calendar now = Calendar.getInstance();
        new DatePickerDialog(this,
                (view, year, month, dayOfMonth) -> {
                    String date = year + "-" + month + "-" + dayOfMonth;
                    binding.tvTargetDate.setText(date);
                },
                now.get(Calendar.YEAR),
                now.get(Calendar.MONTH),
                now.get(Calendar.DAY_OF_MONTH)
        ).show();

    }

    private <T extends SearchableUIField> SearchableUIField getSearchableUIField(Class<T> key) {
        return searchableUIFieldMap.get(key);
    }

    private void onClientContactPersonSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.etClientContact.setText(item.getTitle());
        addServiceDemandRequest.setContactPerson(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onServiceRepresantiveSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.tvResponsiblePersonal.setText(item.getTitle());
        addServiceDemandRequest.setResponsiblePersonel(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onActiveStatusItemSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.tvActiveState.setText(item.getTitle());
        addServiceDemandRequest.setStatus(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onSalesOfficeItemSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.tvSalesOffice.setText(item.getTitle());
        addServiceDemandRequest.setSalesOffice(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onClientItemSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.tvClient.setText(item.getTitle());
        addServiceDemandRequest.setCustomerId(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onCategoriesItemSelected(BaseSearchDialogCompat baseSearchDialogCompat, NameValueResponse.Value item, int index) {
        binding.tvCategory.setText(item.getTitle());
        addServiceDemandRequest.setCategory(item.getValue());
        baseSearchDialogCompat.dismiss();
    }

    private void onSaveServiceDemandClick(View view) {
        Toast.makeText(this, "Save", Toast.LENGTH_LONG).show();
        AddServiceDemandRequest serviceDemandRequest = getServiceDemandFromUI();
        Call<BaseResponse<Object>> addServiceDemandCall = RetrofitBuilder.getsanServices().postAddServiceDemand(baseService.auth, getUsername(), serviceDemandRequest);
        addCall(addServiceDemandCall);
        showProgressDialog();
        addServiceDemandCall.enqueue(new Callback<BaseResponse<Object>>() {
            @Override
            public void onResponse(Call<BaseResponse<Object>> call, Response<BaseResponse<Object>> response) {
                if (response.body() != null && response.body().isSuccessful()) {
                    onNewServiceDemandAddedSuccessfully();
                } else {
                    onNewServiceDemandAddFail();
                }
            }

            @Override
            public void onFailure(Call<BaseResponse<Object>> call, Throwable t) {
                if (!call.isCanceled()){
                    onNewServiceDemandAddFail();
                }
            }
        });

    }

    private void onNewServiceDemandAddFail() {
        showError(getString(R.string.new_service_demand_error));
    }

    private void onNewServiceDemandAddedSuccessfully() {
        finish();
    }

    private void setInitialBindings() {
        binding.setEditable(isEditable());
        binding.executePendingBindings();
    }

    private void setServiceDemandBinding(ServiceDemands.Demand data) {
        binding.setServiceDemand(data);
        binding.executePendingBindings();
    }

    private void fetchServiceDemandDetail() {
        Call<ServiceDemandDetailResponse> demandDetailCall = RetrofitBuilder.getsanServices().getServiceDemandDetail(baseService.auth, getUsername(), getDemandId());
        showProgressDialog();
        addCall(demandDetailCall);
        demandDetailCall.enqueue(new Callback<ServiceDemandDetailResponse>() {
            @Override
            public void onResponse(Call<ServiceDemandDetailResponse> call, Response<ServiceDemandDetailResponse> response) {
                ServiceDemandDetailResponse responseBody = response.body();
                if (response.isSuccessful() && responseBody != null) {
                    setServiceDemandBinding(responseBody.getData());
                } else {
                    onNonSuccessfulResponse();
                }
                hideProgressDialog();
            }

            @Override
            public void onFailure(Call<ServiceDemandDetailResponse> call, Throwable t) {
                hideProgressDialog();
                onNonSuccessfulResponse();
            }
        });
    }

    private void onNonSuccessfulResponse() {
        Toast.makeText(this, R.string.new_service_demand_error, Toast.LENGTH_LONG).show();
    }

    public String getDemandId() {
        return getIntent().getStringExtra(BUNDLE_DEMANDID);
    }

    public String getUsername() {
        return getIntent().getStringExtra(BUNDLE_USERNAME);
    }

    public boolean isEditable() {
        return getIntent().getBooleanExtra(BUNDLE_EDITABLE, false);
    }

    public boolean isNotEditable() {
        return !isEditable();
    }

    public AddServiceDemandRequest getServiceDemandFromUI() {
        addServiceDemandRequest.setDescription(binding.etDefinition.getText().toString());
        addServiceDemandRequest.setTargetDate(binding.tvTargetDate.getText().toString());
        addServiceDemandRequest.setModel(binding.etModel.getText().toString());
        addServiceDemandRequest.setSerialNumber(binding.etSerialNumber.getText().toString());
        addServiceDemandRequest.setMachineLocation(binding.etMachineLocation.getText().toString());
        addServiceDemandRequest.setCallerName(binding.etCallerName.getText().toString());
        addServiceDemandRequest.setCustomerPhone(binding.etPhone.getText().toString());
        addServiceDemandRequest.setNote(binding.etNotes.getText().toString());
        addServiceDemandRequest.setClientContactTitle(binding.etClientContact.getText().toString());
        addServiceDemandRequest.setResponsiblePersonalTitle(binding.tvResponsiblePersonal.getText().toString());
        addServiceDemandRequest.setStatusTitle(binding.tvActiveState.getText().toString());
        addServiceDemandRequest.setSalesOfficeTitle(binding.tvSalesOffice.getText().toString());
        addServiceDemandRequest.setClientTitle(binding.tvClient.getText().toString());
        addServiceDemandRequest.setCategoryTitle(binding.tvCategory.getText().toString());
        return addServiceDemandRequest;
    }


    public boolean isNotDrafted() {
        return !getIntent().hasExtra(BUNDLE_DEMAND);
    }

    public boolean isDraft() {
        return getIntent().hasExtra(BUNDLE_DEMAND);
    }

    public boolean isServiceDemandDetail() {
        return isNotEditable() && isNotDrafted();
    }

    public boolean isServiceDemandDraft() {
        return isDraft();
    }

    public boolean isNewServiceDemand() {
        return isEditable() && isNotDrafted();
    }

    public ServiceDemands.Demand getServiceDemandFromIntent() {
        return getIntent().getParcelableExtra(BUNDLE_DEMAND);
    }
}
