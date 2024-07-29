package com.san.sniper.activities;


import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import androidx.annotation.Nullable;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import androidx.fragment.app.Fragment;
import androidx.core.widget.NestedScrollView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.san.sniper.LogConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.ComplaintNoteAdapter;
import com.san.sniper.adapters.searchdialog.SnpSimpleSearchDialogCompact;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.interfaces.IsanServices;
import com.san.sniper.responsepojos.complaint.ComplaintItemUpdateModel;
import com.san.sniper.responsepojos.complaint.ComplaintUpdateResponse;
import com.san.sniper.responsepojos.response.NameValueResponse;
import com.san.sniper.responsepojos.response.ComplaintResponse;
import com.san.sniper.responsepojos.response.ResponsiblePersonelResponse;
import com.san.sniper.service.BaseService;
import com.google.android.gms.common.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;

import ir.mirrajabi.searchdialog.core.BaseSearchDialogCompat;
import ir.mirrajabi.searchdialog.core.SearchResultListener;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;


/**
 * A simple {@link Fragment} subclass.
 */
public class ComplaintDetailActivity extends BaseActivity {

    protected TextView txtComplaintNo;
    protected TextView txtDescription;
    protected TextView txtCustomer;
    protected TextView txtRelatedPerson;
    protected TextView txtDirectionOfCall;
    protected TextView txtBusinessUnit;
    protected TextView txtDepartment;
    protected TextView txtSubject;
    protected Spinner spinnerStatus;
    protected EditText txtResponsibleEmployee;
    protected LinearLayout layoutSearchResponsibleEmployee;
    protected Spinner spinnerType;
    protected EditText edittextNotes;
    protected FloatingActionButton buttonSave;
    protected RecyclerView notesRecyclerView;
    protected NestedScrollView scrollView;

    SnpSimpleSearchDialogCompact simpleSearchDialogCompat;
    ArrayList<ResponsiblePersonelResponse.Value> responsiblePersonelList;
    ArrayList<NameValueResponse.Value> complaintStatusList;
    ArrayList<NameValueResponse.Value> complaintMessageTypesList;
    ComplaintResponse.Complaint complaint;
    ComplaintNoteAdapter complaintNoteAdapter;
    ResponsiblePersonelResponse.Value selectedResponsiblePersonel;
    String complaintId;
    ProgressDialog progressDialog;
    ArrayAdapter<NameValueResponse.Value> adapterStatus;
    ArrayAdapter<NameValueResponse.Value> adapterType;
    BaseService baseService = new BaseService();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_complaint_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if(getSupportActionBar() != null){
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle(R.string.title_complaint_management_detail);
        }

        complaintId = getIntent().getExtras().getString("complaintId", "");
        Utility.logUsage(LogConstants.Section.COMPLAINT_MANAGEMENT, LogConstants.Activity.VIEW_COMPLAINT,complaintId);
        initView();
        populateActivity();
    }


    private void initView() {
        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage(getString(R.string.please_wait));

        txtComplaintNo = (TextView) findViewById(R.id.txt_complaint_no);
        txtDescription = (TextView) findViewById(R.id.txt_description);
        txtCustomer = (TextView) findViewById(R.id.txt_customer);
        txtRelatedPerson = (TextView) findViewById(R.id.txt_related_person);
        txtDirectionOfCall = (TextView) findViewById(R.id.txt_direction_of_call);
        txtBusinessUnit = (TextView) findViewById(R.id.txt_business_unit);
        txtDepartment = (TextView) findViewById(R.id.txt_department);
        txtSubject = (TextView) findViewById(R.id.txt_subject);
        spinnerStatus = (Spinner) findViewById(R.id.spinner_status);
        txtResponsibleEmployee = (EditText) findViewById(R.id.txt_responsible_employee);
        layoutSearchResponsibleEmployee = (LinearLayout) findViewById(R.id.layout_search_responsible_employee);
        spinnerType = (Spinner) findViewById(R.id.spinner_type);
        edittextNotes = (EditText) findViewById(R.id.edittext_notes);
        buttonSave = (FloatingActionButton) findViewById(R.id.button_save);
        notesRecyclerView = (RecyclerView) findViewById(R.id.notes_list);
        scrollView = (androidx.core.widget.NestedScrollView) findViewById(R.id.scrollView);


        buttonSave.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideKeyboard();
                Utility.logUsage(LogConstants.Section.COMPLAINT_MANAGEMENT, LogConstants.Activity.SAVE_COMPLAINT,complaintId);
                int statusPosition = spinnerStatus.getSelectedItemPosition();
                int typePosition = spinnerType.getSelectedItemPosition();

                String complaintStatusId = adapterStatus.getItem(statusPosition).getValue();
                String completintType = adapterType.getItem(typePosition).getValue();

                if (edittextNotes.getText().toString().length() > 0 && !"".equals(complaintStatusId) && !"".equals(completintType)) {

                    ComplaintItemUpdateModel updateModel = new ComplaintItemUpdateModel();

                    ComplaintResponse.Text myText = new ComplaintResponse().new Text();
                    myText.setNote(edittextNotes.getText().toString());
                    myText.setType(completintType);
                    ArrayList<ComplaintResponse.Text> myList = new ArrayList<>();

                    myList.add(myText);


                    updateModel.setStatusId(complaintStatusId);
                    updateModel.setResponsiblePersonelId(selectedResponsiblePersonel.getValue());
                    updateModel.setId(complaintId);
                    updateModel.setTexts(myList);

                    progressDialog.show();
                    Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
                    IsanServices ibs = retrofit.create(IsanServices.class);
                    Call<ComplaintUpdateResponse> call = ibs.updateComplaint(baseService.auth, baseService.username, updateModel);
                    call.enqueue(new Callback<ComplaintUpdateResponse>() {
                        @Override
                        public void onResponse(Call<ComplaintUpdateResponse> call, Response<ComplaintUpdateResponse> updateResponse) {
                            if (updateResponse.body() != null) {
                                updateResponse.body().showMessages(getApplicationContext());
                            }
                            reloadActivity();

                        }

                        @Override
                        public void onFailure(Call<ComplaintUpdateResponse> call, Throwable t) {
                            Toast.makeText(getApplicationContext(), getString(R.string.new_service_demand_error), Toast.LENGTH_LONG).show();

                        }
                    });


                } else {
                    Toast.makeText(getApplicationContext(), getString(R.string.please_fill_all_areas), Toast.LENGTH_SHORT).show();
                }


            }
        });
        layoutSearchResponsibleEmployee.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getResponsiblePersonels();
            }
        });


        scrollView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                hideKeyboard();
                return false;
            }
        });


        txtResponsibleEmployee.setCursorVisible(false);
        txtResponsibleEmployee.setLongClickable(false);
        txtResponsibleEmployee.setClickable(false);
        txtResponsibleEmployee.setFocusable(false);
        txtResponsibleEmployee.setSelected(false);
        txtResponsibleEmployee.setKeyListener(null);
        notesRecyclerView.setLayoutManager(new LinearLayoutManager(getApplicationContext()));
        notesRecyclerView.setNestedScrollingEnabled(false);

    }

    void reloadActivity(){
        Intent intent = getIntent();
        overridePendingTransition(0, 0);
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
        finish();
        overridePendingTransition(0, 0);
        startActivity(intent);
    }
    void hideKeyboard() {
        InputMethodManager imm = (InputMethodManager) this.getSystemService(INPUT_METHOD_SERVICE);
        if(getCurrentFocus()!= null){
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
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

    private void populateActivity(){
        prpComplaints(() -> prpStatus(this::prpMessageTypes));

    }
    private void prpComplaints(Runnable nextTask) {
        progressDialog.show();
        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);
        Call<ComplaintResponse> call = ibs.complaintDetail(baseService.auth, baseService.username, complaintId);
        call.enqueue(new Callback<ComplaintResponse>() {
            @Override
            public void onResponse(Call<ComplaintResponse> call, Response<ComplaintResponse> response) {
                ComplaintResponse complaintResponse = response.body();
                if (complaintResponse != null && complaintResponse.isSuccessful()) {
                    if (complaintResponse.getMessages() != null && !complaintResponse.getMessages().isEmpty()) {
                        String message = "";
                        for (String m : complaintResponse.getMessages()) {
                            message += m + "\n";
                        }
                        showMessage("", message);
                    }
                    if (complaintResponse.getData() != null && complaintResponse.getData().getComplaints() != null) {
                        if (!complaintResponse.getData().getComplaints().isEmpty()) {
                            populateViews(complaintResponse.getData().getComplaints().get(0));
                            nextTask.run();
                            return;
                        }
                    }
                }else if(complaintResponse != null){
                    complaintResponse.showMessages(getApplicationContext());
                }
                progressDialog.dismiss();
            }

            @Override
            public void onFailure(Call<ComplaintResponse> call, Throwable t) {
                Log.e("ComplaintDetailActivity", t.getMessage());
                progressDialog.dismiss();
            }
        });
    }

    private void prpStatus(Runnable nextTask) {
        progressDialog.show();
        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);
        Call<NameValueResponse> call = ibs.complaintStatus(baseService.auth, baseService.username);
        call.enqueue(new Callback<NameValueResponse>() {
            @Override
            public void onResponse(Call<NameValueResponse> call, Response<NameValueResponse> response) {
                NameValueResponse complaintNameValueResponse = response.body();

                if (complaintNameValueResponse != null && complaintNameValueResponse.isSuccessful()) {
                    if (complaintNameValueResponse.getMessages() != null && !complaintNameValueResponse.getMessages().isEmpty()) {
                        String message = "";
                        for (String m : complaintNameValueResponse.getMessages()) {
                            message += m + "\n";
                        }
                        showMessage("", message);
                    }
                    if (complaintNameValueResponse.getData() != null && complaintNameValueResponse.getData().getValues() != null) {
                        if (!complaintNameValueResponse.getData().getValues().isEmpty()) {
                            List<NameValueResponse.Value> list = complaintNameValueResponse.getData().getValues();
                            complaintStatusList = new ArrayList<>(list);
                            adapterStatus =
                                    new ArrayAdapter<NameValueResponse.Value>(ComplaintDetailActivity.this, android.R.layout.simple_spinner_dropdown_item, complaintStatusList);
                            adapterStatus.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                            spinnerStatus.setAdapter(adapterStatus);


                            for (int i = 0; i < complaintStatusList.size(); i++) {
                                if (complaint.getStatusId().equals(complaintStatusList.get(i).getValue())) {
                                    spinnerStatus.setSelection(i);
                                }
                            }
                            nextTask.run();
                            return;
                        }
                    }
                }else if (complaintNameValueResponse != null){
                    complaintNameValueResponse.showMessages(getApplicationContext());
                }
                progressDialog.dismiss();
            }

            @Override
            public void onFailure(Call<NameValueResponse> call, Throwable t) {
                Log.e("ComplaintDetailActivity", t.getMessage());
                progressDialog.dismiss();
            }
        });
    }

    private void prpMessageTypes() {
        progressDialog.show();
        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);
        Call<NameValueResponse> call = ibs.complaintMessageTypes(baseService.auth, baseService.username);
        call.enqueue(new Callback<NameValueResponse>() {
            @Override
            public void onResponse(Call<NameValueResponse> call, Response<NameValueResponse> response) {
                NameValueResponse complaintNameValueResponse = response.body();

                if (complaintNameValueResponse != null && complaintNameValueResponse.isSuccessful()) {
                    if (complaintNameValueResponse.getMessages() != null && !complaintNameValueResponse.getMessages().isEmpty()) {
                        String message = "";
                        for (String m : complaintNameValueResponse.getMessages()) {
                            message += m + "\n";
                        }
                        showMessage("", message);
                    }
                    if (complaintNameValueResponse.getData() != null && complaintNameValueResponse.getData().getValues() != null) {
                        if (!complaintNameValueResponse.getData().getValues().isEmpty()) {
                            List<NameValueResponse.Value> list = complaintNameValueResponse.getData().getValues();
                            complaintNoteAdapter.setComplaintMessageTypesList(list);
                            complaintMessageTypesList = new ArrayList<>(list);
                            adapterType =
                                    new ArrayAdapter<NameValueResponse.Value>(ComplaintDetailActivity.this, android.R.layout.simple_spinner_dropdown_item, complaintMessageTypesList);
                            adapterType.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                            spinnerType.setAdapter(adapterType);
                        }
                    }
                }else if(complaintNameValueResponse != null){
                    complaintNameValueResponse.showMessages(getApplicationContext());
                }
                progressDialog.dismiss();
            }

            @Override
            public void onFailure(Call<NameValueResponse> call, Throwable t) {
                Log.e("ComplaintDetailActivity", t.getMessage());
                progressDialog.dismiss();
            }
        });
    }


    private void getResponsiblePersonels() {
        if (responsiblePersonelList != null) {
            showResponsibleEmployeesDialog(responsiblePersonelList);
        } else {
            progressDialog.show();
            Retrofit retrofit = RetrofitBuilder.getRetrofit(ComplaintDetailActivity.this.getApplication());
            IsanServices ibs = retrofit.create(IsanServices.class);
            Call<ResponsiblePersonelResponse> call = ibs.complaintResponsiblePersonel(baseService.auth, baseService.username);
            call.enqueue(new Callback<ResponsiblePersonelResponse>() {
                @Override
                public void onResponse(Call<ResponsiblePersonelResponse> call, Response<ResponsiblePersonelResponse> response) {
                    ResponsiblePersonelResponse responsiblePersonelResponse = response.body();

                    if (responsiblePersonelResponse != null && responsiblePersonelResponse.isSuccessful()) {
                        if (responsiblePersonelResponse.getMessages() != null && !responsiblePersonelResponse.getMessages().isEmpty()) {
                            String message = "";
                            for (String m : responsiblePersonelResponse.getMessages()) {
                                message += m + "\n";
                            }
                            showMessage("", message);
                        }
                        if (responsiblePersonelResponse.getData() != null && responsiblePersonelResponse.getData().getValues() != null) {
                            if (!responsiblePersonelResponse.getData().getValues().isEmpty()) {
                                List<ResponsiblePersonelResponse.Value> list = responsiblePersonelResponse.getData().getValues();
                                responsiblePersonelList = new ArrayList<ResponsiblePersonelResponse.Value>(list);
                                showResponsibleEmployeesDialog(responsiblePersonelList);
                            }
                        }
                    }else if(responsiblePersonelResponse != null){
                        responsiblePersonelResponse.showMessages(getApplicationContext());
                    }
                    progressDialog.dismiss();
                }

                @Override
                public void onFailure(Call<ResponsiblePersonelResponse> call, Throwable t) {
                    Log.e("ComplaintDetailActivity", t.getMessage());
                    progressDialog.dismiss();
                }
            });
        }
    }

    private void showMessage(String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(ComplaintDetailActivity.this);
        builder.setTitle(title)
                .setMessage(message)
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }

    private void populateViews(ComplaintResponse.Complaint complaintResponsecomplaint) {
        this.complaint = complaintResponsecomplaint;
        txtComplaintNo.setText(complaint.getId());
        txtDescription.setText(complaint.getDescription());
        txtCustomer.setText(complaint.getCustomerName());
        txtRelatedPerson.setText(complaint.getContactPerson());
        txtDirectionOfCall.setText(complaint.getDirectionOfCall());
        txtBusinessUnit.setText(complaint.getBusiness());
        txtDepartment.setText(complaint.getDepartment());
        txtSubject.setText(complaint.getTopic());
        txtResponsibleEmployee.setText(complaint.getResponsiblePersonel());

        selectedResponsiblePersonel = new ResponsiblePersonelResponse().new Value();

        selectedResponsiblePersonel.setName(complaint.getResponsiblePersonel());
        selectedResponsiblePersonel.setValue(complaint.getResponsiblePersonelId());


        if (complaint.getTexts() != null) {
            complaintNoteAdapter = new ComplaintNoteAdapter(complaint.getTexts());
            notesRecyclerView.setAdapter(complaintNoteAdapter);
        }
        spinnerStatus.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        spinnerType.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void showResponsibleEmployeesDialog(ArrayList<ResponsiblePersonelResponse.Value> list) {

        simpleSearchDialogCompat = new SnpSimpleSearchDialogCompact(this, getString(R.string.responsible_employees),
                getString(R.string.search), null, list,
                new SearchResultListener<ResponsiblePersonelResponse.Value>() {
                    @Override
                    public void onSelected(BaseSearchDialogCompat dialog,
                                           ResponsiblePersonelResponse.Value item, int position) {

                        Toast.makeText(ComplaintDetailActivity.this, item.getTitle(),
                                Toast.LENGTH_SHORT).show();


                        selectedResponsiblePersonel = item;
                        txtResponsibleEmployee.setText(item.getName());
                        dialog.dismiss();
                    }
                });


        int width = (int) (getResources().getDisplayMetrics().widthPixels * 0.90);
        int height = (int) (getResources().getDisplayMetrics().heightPixels * 0.90);

        simpleSearchDialogCompat.show();
        simpleSearchDialogCompat.getWindow().setLayout(width, height);

    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {

        super.onConfigurationChanged(newConfig);
        int currentOrientation = getResources().getConfiguration().orientation;

        //Orientation değiştiğinde search diyaloğun genişliğini tekrar ayarlamak için.
        if (simpleSearchDialogCompat != null) {
            int width = (int) (getResources().getDisplayMetrics().widthPixels * 0.90);
            int height = (int) (getResources().getDisplayMetrics().heightPixels * 0.90);
            simpleSearchDialogCompat.getWindow().setLayout(width, height);

        }
    }


}
