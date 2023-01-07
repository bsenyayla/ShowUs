package com.san.sniper.activities;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.net.Uri;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.format.Formatter;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bestsoft32.tt_fancy_gif_dialog_lib.TTFancyGifDialog;
import com.bestsoft32.tt_fancy_gif_dialog_lib.TTFancyGifDialogListener;
import com.san.sniper.DataKeys;
import com.san.sniper.AppConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.customersearch.FilterableSearchTypeListAdapter;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.entity.RecentSearchEntity;
import com.san.sniper.enums.CustomerFilterType;
import com.san.sniper.enums.CustomerSearchType;
import com.san.sniper.interfaces.IsanServices;
import com.san.sniper.requestpojos.CustomerFieldWorkUpladFileRequest;
import com.san.sniper.requestpojos.CustomerSearchRequest;
import com.san.sniper.responsepojos.customerfieldwork.Customer;
import com.san.sniper.responsepojos.response.CustomerResponse;
import com.san.sniper.service.BaseService;
import com.san.sniper.service.CustomerService;
import com.san.sniper.singletons.DataTransfer;
import com.san.sniper.singletons.SniperUser;
import com.san.sniper.utility.TimeEditText;
import com.san.sniper.views.FilterableSearchView;
import com.san.sniper.views.LabelledSpinner;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.reflect.TypeToken;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;

import droidninja.filepicker.FilePickerBuilder;
import droidninja.filepicker.FilePickerConst;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class AddCustomerFieldWorkFormActivity extends AppCompatActivity implements FilterableSearchView.OnQueryTextListener, FilterableSearchTypeListAdapter.OnFilterTypeClickListener {

    LabelledSpinner spinnerCustomerName, spinnerBrand, spinnerModel, spinnerMaterial;
    BaseService baseService = new BaseService();
    CustomerFieldWorkUpladFileRequest customerFieldWorkUpladFileRequest = new CustomerFieldWorkUpladFileRequest();
    EditText productionYear, referenceDocument, bucketCapacity, configuration, loadingVehicle, competitorMachine, fuel, production, efficiency,
            operatorComment, customerComment, salesRepresantativeComment;
    ProgressBar pbLoading;
    TextView txtAddedImage;
    Button addAttachmentImage, addAttachmentPdf;
    ArrayList<FileUri> selectedFiles = new ArrayList<>();
    ProgressDialog progressDialog;
    final int fileLimit = 15;
    long totalSize = 0;
    long totalSizelimit = 26214400;//25mb
    EditText totalWorkingHour, totalWorkingMinute;
    ImageView ivButtonFilterCustomers;

    //Customer Search
    List<CustomerResponse.SingleCustomer> customers = new ArrayList<>();
    HashMap<String, CustomerResponse.SingleCustomer> myMap = new HashMap<>();

    private FilterableSearchView filterableSearchView;
    SharedPreferences preferences;
    CustomerSearchRequest customerSearchRequest;
    CustomerSearchType selectedSearchType;
    CustomerService customerService = new CustomerService();

    public class FileUri {
        Uri uri;
        int type;
        String path;
        String name;
        String mimeType;

        FileUri(Uri uri, int type, String path, String name, String mimeType) {
            this.uri = uri;
            this.type = type;
            this.path = path;
            this.name = name;
            this.mimeType = mimeType;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getMimeType() {
            return mimeType;
        }

        public Uri getUri() {
            return uri;
        }

        public void setUri(Uri uri) {
            this.uri = uri;
        }

        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
        }

        public String getPath() {
            return path;
        }

        public void setPath(String path) {
            this.path = path;
        }


    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_customer_field_work_add_form);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getString(R.string.title_create_field_work));
        preferences = getSharedPreferences("RunningAssistant.preferences", Context.MODE_PRIVATE);

        pbLoading = findViewById(R.id.pbLoading);
        spinnerCustomerName = findViewById(R.id.spinnerCustomerName);
        spinnerBrand = findViewById(R.id.spinnerBrand);
        spinnerModel = findViewById(R.id.spinnerModel);
        spinnerMaterial = findViewById(R.id.spinnerMaterial);
        txtAddedImage = findViewById(R.id.txtAddedImage);
        String txt = getString(R.string.file_limit_added) + " 0  / " + fileLimit;
        txtAddedImage.setText(txt);
        totalWorkingHour = findViewById(R.id.totalWorkingHour);
        totalWorkingMinute = findViewById(R.id.totalWorkingMinute);
        ivButtonFilterCustomers = findViewById(R.id.image_button_filter_customers);

        productionYear = findViewById(R.id.productionYear);
        referenceDocument = findViewById(R.id.referenceDocument);
        bucketCapacity = findViewById(R.id.bucketCapacity);
        configuration = findViewById(R.id.configuration);
        loadingVehicle = findViewById(R.id.loadingVehicle);
        competitorMachine = findViewById(R.id.competitorMachine);
        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.setCancelable(false);

        //prepare searchview
        filterableSearchView = findViewById(R.id.filterable_search_view);
        filterableSearchView.setOnFilterTypeClickListener(this);
        filterableSearchView.setOnQueryTextListener(this);
        filterableSearchView.setCustomerService(customerService);
        filterableSearchView.initFilters(CustomerFilterType.ONLY_CUSTOMER.getValue());
        filterableSearchView.setRecentSearchList(getRecentSearchList());
        selectedSearchType = CustomerSearchType.CUSTOMER_INFORMATION;

        ivButtonFilterCustomers.setOnClickListener(v -> {
            filterableSearchView.updateRecentSearchList(getRecentSearchList());
            filterableSearchView.startSearcherAnimation();
        });

        fuel = findViewById(R.id.fuel);
        production = findViewById(R.id.production);
        efficiency = findViewById(R.id.efficiency);
        operatorComment = findViewById(R.id.operatorComment);
        customerComment = findViewById(R.id.customerComment);
        salesRepresantativeComment = findViewById(R.id.salesRepresantativeComment);
        addAttachmentImage = findViewById(R.id.addAttachmentImage);
        addAttachmentPdf = findViewById(R.id.addAttachmentPdf);
        addAttachmentImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                FilePickerBuilder.getInstance()
                        .setMaxCount(5) //optional
                        .enableVideoPicker(true)
                        .setActivityTheme(R.style.LibAppTheme) //optional
                        .pickPhoto(AddCustomerFieldWorkFormActivity.this);
            }
        });

        addAttachmentPdf.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                FilePickerBuilder.getInstance()
                        .setMaxCount(5) //optional
                        .setActivityTheme(R.style.LibAppTheme) //optional
                        .pickFile(AddCustomerFieldWorkFormActivity.this);
            }
        });


        fuel.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                calculateRate(s.toString(), production.getText().toString());

            }
        });


        production.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                calculateRate(fuel.getText().toString(), s.toString());

            }
        });


        FloatingActionButton fabSendForm = findViewById(R.id.fabSendForm);
        fabSendForm.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                letsSendRequest();
            }
        });
        TextView txtCustomerNumber = findViewById(R.id.txtCustomerNumber);
        spinnerCustomerName.setOnItemSelectedListener(() -> {
            String value = spinnerCustomerName.getSelectedItem(String.class);
            CustomerResponse.SingleCustomer customer = myMap.get(value);
            txtCustomerNumber.setText(Utility.trimLeadingZeros(customer.getCustomerId()));
            customerFieldWorkUpladFileRequest.setCustomerName(customer.getName());
            customerFieldWorkUpladFileRequest.setCustomerNumber(customer.getCustomerId());
            customerFieldWorkUpladFileRequest.setApplication("Sniper");

        });

        List<String> cat_non_cat = Arrays.asList(getResources().getStringArray(R.array.cat_non_cat));
        spinnerBrand.setData(cat_non_cat);

        List<String> material_list = Arrays.asList(getResources().getStringArray(R.array.material_list));
        spinnerMaterial.setData(material_list);
        spinnerMaterial.setOnItemSelectedListener(() -> {
            String materialSelectedItem = spinnerMaterial.getSelectedItem(String.class);
            String[] materialItems = materialSelectedItem.split("/");
            customerFieldWorkUpladFileRequest.setMaterialName(materialItems[0]);
            customerFieldWorkUpladFileRequest.setMaterialDensity(Double.parseDouble(materialItems[1]));

        });

        spinnerBrand.setOnItemSelectedListener(() -> {
            String brand = spinnerBrand.getSelectedItem(String.class);
            customerFieldWorkUpladFileRequest.setBrand(brand);
            getBrands(brand);
        });

        spinnerModel.setOnItemSelectedListener(() -> {
            String model = spinnerModel.getSelectedItem(String.class);
            customerFieldWorkUpladFileRequest.setModel(model);

        });
        getCustomers();

    }

    private void calculateRate(String myFuel, String myProduction) {
        if (Utility.stringIsNotEmpty(myFuel) && Utility.stringIsNotEmpty(myProduction)) {
            Double result = Double.parseDouble(myProduction) / Double.parseDouble(myFuel);
            NumberFormat nf = NumberFormat.getNumberInstance(Locale.ENGLISH);
            DecimalFormat formatter = (DecimalFormat) nf;
            formatter.applyPattern("#.####");
            String fString = formatter.format(result);
            efficiency.setText(fString);
        } else {
            efficiency.setText("");
        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public boolean onCreateOptionsMenu(Menu menu) {
        return true;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {


            case FilePickerConst.REQUEST_CODE_PHOTO:
                if (resultCode == RESULT_OK && data != null) {
                    ArrayList<Uri> list = data.getParcelableArrayListExtra(FilePickerConst.KEY_SELECTED_MEDIA);
                    int sizeOflist = list.size();
                    for (int i = 0; i < list.size(); i++) {
                        String path = Utility.getRealPathFromURI(this, list.get(i));
                        String name = Utility.getFileName(path);
                        String mimeType = Utility.getMimeType(list.get(i), this);
                        FileUri fileUri = new FileUri(list.get(i), 0, path, name, mimeType);
                        if (fileLimit >= selectedFiles.size() + sizeOflist) {
                            selectedFiles.add(fileUri);
                            sizeOflist--;
                        } else {
                            Toast.makeText(getApplicationContext(), getString(R.string.file_limit), Toast.LENGTH_SHORT).show();
                            break;
                        }

                    }

                    GenerateImages(selectedFiles);
                }
                break;
            case FilePickerConst.REQUEST_CODE_DOC:
                if (resultCode == RESULT_OK && data != null) {
                    ArrayList<Uri> list = data.getParcelableArrayListExtra(FilePickerConst.KEY_SELECTED_DOCS);
                    int sizeOflist = list.size();
                    for (int i = 0; i < list.size(); i++) {
                        String path = Utility.getRealPathFromURI(this, list.get(i));
                        String name = Utility.getFileName(path);
                        String mimeType = Utility.getMimeType(list.get(i), this);
                        FileUri fileUri = new FileUri(list.get(i), 1, path, name, mimeType);
                        if (fileLimit >= selectedFiles.size() + sizeOflist) {
                            selectedFiles.add(fileUri);
                            sizeOflist--;
                        } else {
                            Toast.makeText(getApplicationContext(), getString(R.string.file_limit), Toast.LENGTH_SHORT).show();
                            break;
                        }

                    }
                    GenerateImages(selectedFiles);

                }
                break;
        }

    }

    private void GenerateImages(ArrayList<FileUri> mySelectedImages) {

        if (fileLimit >= mySelectedImages.size()) {
            LinearLayout linearLayout = findViewById(R.id.myImageContent);
            linearLayout.removeAllViews();
            totalSize = 0;
            for (int i = 0; i < mySelectedImages.size(); i++) {
                FileUri fileUri = mySelectedImages.get(i);
                View child = getLayoutInflater().inflate(R.layout.attachment_image, null);
                TextView txtMb = child.findViewById(R.id.txtMb);
                ImageView ivContent = child.findViewById(R.id.ivContent);
                ImageView ivDelete = child.findViewById(R.id.ivDelete);
                File file = new File(mySelectedImages.get(i).getPath());
                txtMb.setText(Formatter.formatFileSize(getApplicationContext(), file.length()));
                totalSize = totalSize + file.length();
                int finalI = i;
                ivDelete.setOnClickListener(view -> {
                    mySelectedImages.remove(finalI);
                    GenerateImages(mySelectedImages);
                });
                if (fileUri.getType() == 0) {
                    Glide.with(getApplicationContext())
                            .load(fileUri.getUri())
                            .apply(new RequestOptions().fitCenter().diskCacheStrategy(DiskCacheStrategy.ALL))
                            .into(ivContent);
                } else {
                    Glide.with(getApplicationContext())
                            .load(R.drawable.icon_file_unknown)
                            .apply(new RequestOptions().fitCenter().diskCacheStrategy(DiskCacheStrategy.ALL))
                            .into(ivContent);
                }

                linearLayout.addView(child);
            }
            String message = getString(R.string.file_limit_added) + mySelectedImages.size() +
                    " / " + fileLimit + "\n" + Formatter.formatShortFileSize(getApplicationContext(), totalSize);
            txtAddedImage.setText(message);
        } else {
            Toast.makeText(getApplicationContext(), getString(R.string.file_limit), Toast.LENGTH_SHORT).show();

        }


    }

    public void letsSendRequest() {


        if (checkMandatoryFields()) {

            if (Utility.stringIsNotEmpty(totalWorkingMinute.getText().toString())) {
                String hour = totalWorkingHour.getText().toString();
                if ("".equals(hour)) {
                    hour = "00";
                } else {
                    if (hour.length() < 2) {
                        hour = "0" + hour;
                    }
                }
                String minute = totalWorkingMinute.getText().toString();
                if (minute.length() < 2) {
                    minute = "0" + minute;
                }

                customerFieldWorkUpladFileRequest.setTotalWorkingTime(prpTime(hour + ":" + minute));
            } else {
                customerFieldWorkUpladFileRequest.setTotalWorkingTime(0.0);
            }

            if (Utility.stringIsNotEmpty(productionYear.getText().toString())) {
                customerFieldWorkUpladFileRequest.setProductionYear(Integer.parseInt(productionYear.getText().toString()));
            } else {
                customerFieldWorkUpladFileRequest.setProductionYear(0);

            }
            if (Utility.stringIsNotEmpty(bucketCapacity.getText().toString())) {
                customerFieldWorkUpladFileRequest.setBucketCapacity(Double.parseDouble(bucketCapacity.getText().toString()));
            } else {
                customerFieldWorkUpladFileRequest.setBucketCapacity(0.0);

            }
            if (Utility.stringIsNotEmpty(configuration.getText().toString())) {
                customerFieldWorkUpladFileRequest.setConfiguration(configuration.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setConfiguration("");
            }

            if (Utility.stringIsNotEmpty(loadingVehicle.getText().toString())) {
                customerFieldWorkUpladFileRequest.setLoadingVehicle(loadingVehicle.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setLoadingVehicle("");
            }
            if (Utility.stringIsNotEmpty(competitorMachine.getText().toString())) {
                customerFieldWorkUpladFileRequest.setCompetitorMachine(competitorMachine.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setCompetitorMachine("");
            }
            if (Utility.stringIsNotEmpty(fuel.getText().toString())) {
                customerFieldWorkUpladFileRequest.setFuel(Double.parseDouble(fuel.getText().toString()));
            } else {
                customerFieldWorkUpladFileRequest.setFuel(0.0);
            }
            if (Utility.stringIsNotEmpty(production.getText().toString())) {
                customerFieldWorkUpladFileRequest.setProduction(Double.parseDouble(production.getText().toString()));
            } else {
                customerFieldWorkUpladFileRequest.setProduction(0.0);
            }
            if (Utility.stringIsNotEmpty(efficiency.getText().toString())) {
                customerFieldWorkUpladFileRequest.setEfficiency(Double.parseDouble(efficiency.getText().toString()));
            } else {
                customerFieldWorkUpladFileRequest.setEfficiency(0.0);
            }

            if (Utility.stringIsNotEmpty(operatorComment.getText().toString())) {
                customerFieldWorkUpladFileRequest.setOperatorComment(operatorComment.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setOperatorComment("");
            }

            if (Utility.stringIsNotEmpty(customerComment.getText().toString())) {
                customerFieldWorkUpladFileRequest.setCustomerComment(customerComment.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setCustomerComment("");
            }

            if (Utility.stringIsNotEmpty(salesRepresantativeComment.getText().toString())) {
                customerFieldWorkUpladFileRequest.setSalesRepresantativeComment(salesRepresantativeComment.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setSalesRepresantativeComment("");
            }

            if (Utility.stringIsNotEmpty(referenceDocument.getText().toString())) {
                customerFieldWorkUpladFileRequest.setReferenceDocument(referenceDocument.getText().toString());
            } else {
                customerFieldWorkUpladFileRequest.setReferenceDocument("");
            }
            customerFieldWorkUpladFileRequest.setId(1);
            //customerFieldWorkUpladFileRequest.setTotalWorkingTime(prpTime());
            customerFieldWorkUpladFileRequest.setCreatorFirstName(baseService.username);
            uploadImage(customerFieldWorkUpladFileRequest);
        } else {
            Toast.makeText(getApplicationContext(), getString(R.string.please_fill_all_areas), Toast.LENGTH_SHORT).show();
        }
    }

    private boolean checkMandatoryFields() {

        boolean result = true;


        if (Utility.stringIsNotEmpty(totalWorkingMinute.getText().toString())) {
            totalWorkingMinute.getBackground().clearColorFilter();
        } else {
            totalWorkingMinute.getBackground().setColorFilter(Color.RED, PorterDuff.Mode.SRC_IN);
            result = false;
        }
        if (Utility.stringIsNotEmpty(fuel.getText().toString())) {
            fuel.getBackground().clearColorFilter();
        } else {
            fuel.getBackground().setColorFilter(Color.RED, PorterDuff.Mode.SRC_IN);
            result = false;
        }
        if (Utility.stringIsNotEmpty(production.getText().toString())) {
            production.getBackground().clearColorFilter();
        } else {
            production.getBackground().setColorFilter(Color.RED, PorterDuff.Mode.SRC_IN);
            result = false;
        }
        if (Utility.stringIsNotEmpty(salesRepresantativeComment.getText().toString())) {
            salesRepresantativeComment.getBackground().clearColorFilter();
        } else {
            salesRepresantativeComment.getBackground().setColorFilter(Color.RED, PorterDuff.Mode.SRC_IN);
            result = false;
        }
        return result;


    }

    private double prpTime(String workingTime) {


        if (!workingTime.equals("")) {
            String[] parts = workingTime.split(":");
            double hours = Double.parseDouble(parts[0]);
            double minutes = 0.0;
            if (parts.length > 1) {
                minutes = Double.parseDouble(parts[1]);
            }

            return (hours * 60) + minutes;
        }
        return 0.0;

    }

    public void uploadImage(CustomerFieldWorkUpladFileRequest customerFieldWorkRequest) {

        if (totalSizelimit > totalSize) {
            progressDialog.show();
            Gson gson = new Gson();
            String json = gson.toJson(customerFieldWorkRequest);

            List<MultipartBody.Part> fileArray = new ArrayList<>();

            for (int i = 0; i < selectedFiles.size(); i++) {
                FileUri fileUri = selectedFiles.get(i);
                String extension = fileUri.getPath().substring(fileUri.getPath().lastIndexOf(".") + 1);
                File finalFile;
                if (extension.contains("jpg") || extension.contains("png")) {
                    finalFile = Utility.compressImage(this, new File(fileUri.getPath()));
                } else {
                    finalFile = new File(fileUri.getPath());
                }
                String lastFileName = "";
                try {
                    lastFileName = URLEncoder.encode(fileUri.getName().replaceAll(" ", "%20"), "utf-8");
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                    lastFileName = String.valueOf(System.currentTimeMillis());
                }

                MultipartBody.Part filePart = MultipartBody.Part.createFormData("file",
                        lastFileName + "." + extension,
                        RequestBody.create(MediaType.parse(fileUri.getMimeType()), finalFile));
                fileArray.add(i, filePart);
            }

            Retrofit retrofit = RetrofitBuilder.getRetrofit(this.getApplication());
            IsanServices ibs = retrofit.create(IsanServices.class);
            MultipartBody.Part form = MultipartBody.Part.createFormData("form", json);
            Call<String> call = ibs.uploadCustomerFieldWorkMedia(SniperUser.getInstance().auth, form, fileArray);
            call.enqueue(new Callback<String>() {
                @Override
                public void onResponse(Call<String> call, @NotNull Response<String> response) {
                    progressDialog.dismiss();
                    if (response.isSuccessful() && response.body() != null && Utility.isJSONValid(response.body())) {

                        showSuccessDialog();
                    } else {
                        //showAlert(response.body());
                        Toast.makeText(getApplicationContext(), getString(R.string.customer_field_form_successfully_error), Toast.LENGTH_LONG).show();

                    }

                }

                @Override
                public void onFailure(Call<String> call, Throwable t) {
                    progressDialog.dismiss();
                    Toast.makeText(getApplicationContext(), t.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                }
            });

        } else {
            Toast.makeText(getApplicationContext(), getString(R.string.file_total_size), Toast.LENGTH_SHORT).show();
        }


    }

    public void getBrands(String brand) {

        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);
        Call<List<String>> responseCall = ibs.getFieldWorkCategories(baseService.auth, brand);
        responseCall.enqueue(new Callback<List<String>>() {
            @Override
            public void onResponse(Call<List<String>> call, Response<List<String>> response) {
                if (response.isSuccessful()) {
                    spinnerModel.setData(response.body());
                } else {
                    spinnerModel.setData(new ArrayList<>());
                }
                pbLoading.setVisibility(View.GONE);
            }

            @Override
            public void onFailure(Call<List<String>> call, Throwable t) {
                pbLoading.setVisibility(View.GONE);
            }
        });
    }

    public void getCustomers() {
        customers = DataTransfer.getInstance().getData(DataKeys.CUSTOMER_LIST, List.class);
        if(customers != null){
            customersOnReady(customers);
            return;
        }

        pbLoading.setVisibility(View.VISIBLE);
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
            touchSpinner(spinnerCustomerName.getSpinner());
        });
    }

    public void customersOnReady(List<com.san.sniper.responsepojos.response.CustomerResponse.SingleCustomer> customerList){
        myMap.clear();
        for (int i = 0; i < customerList.size(); i++) {
            myMap.put(customers.get(i).getName(), customers.get(i));
        }

        Set<String> keys = myMap.keySet();
        ArrayList<String> myList = new ArrayList<>(keys);
        spinnerCustomerName.setData(myList);
    }

    public void refreshData() {
        Intent data = new Intent();
        setResult(RESULT_OK, data);
        finish();
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
            touchSpinner(spinnerCustomerName.getSpinner());
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

    public static void showKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        View view = activity.getCurrentFocus();
        if (view == null) {
            view = new View(activity);
        }
        imm.toggleSoftInputFromWindow(view.getWindowToken(), InputMethodManager.SHOW_FORCED,0);
    }

    private void showAlert(String error) {
        AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
        builder1.setMessage(error);
        builder1.setCancelable(true);

        builder1.setPositiveButton(
                getString(R.string.ok),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });


        AlertDialog alert11 = builder1.create();
        alert11.show();
    }

    private void showSuccessDialog() {

        new TTFancyGifDialog.Builder(AddCustomerFieldWorkFormActivity.this)
                .setMessage(getString(R.string.customer_field_form_successfully_sent)).setPositiveBtnText(getString(R.string.ok))
                .setPositiveBtnBackground("#FDBA12")
                .setGifResource(R.drawable.success_icon)
                .isCancellable(true)
                .OnPositiveClicked(new TTFancyGifDialogListener() {
                    @Override
                    public void OnClick() {
                        refreshData();
                    }
                })
                .build();


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
}
