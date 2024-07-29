package com.san.sniper.activities;

import android.app.Dialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;

import android.os.Environment;
import android.os.StrictMode;
import android.util.Base64;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.webkit.MimeTypeMap;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;


import com.san.sniper.CreateOffer.CreateOfferActivity;
import com.san.sniper.DataKeys;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.OfferProductsAdapter;
import com.san.sniper.adapters.SimpleListItemRVAdapter;
import com.san.sniper.requestpojos.quotation.CreateOfferRequestBody;
import com.san.sniper.requestpojos.quotation.OfferItem;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.checkin.KeyValuePair;
import com.san.sniper.responsepojos.checkin.NoteType;
import com.san.sniper.responsepojos.common.Note;
import com.san.sniper.responsepojos.createoffer.QuotationDetailResponseBody;
import com.san.sniper.responsepojos.customer.CustomerDetailModel;
import com.san.sniper.responsepojos.mdoffers.OfferDetail;
import com.san.sniper.responsepojos.mdoffers.OfferInfo;
import com.san.sniper.responsepojos.mdoffers.OfferProduct;
import com.san.sniper.responsepojos.quotation.QuotationOutput;
import com.san.sniper.responsepojos.relatedperson.RelatedPersonList;
import com.san.sniper.responsepojos.response.CustomerResponse;
import com.san.sniper.service.BaseService;
import com.san.sniper.singletons.DataTransfer;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class MdOfferActivity extends BaseActivity {

    public static final String MD_OFFER_ID = "MD_OFFER_ID";
    protected Toolbar toolbar;
    protected TextView customerSelection, customerNo, billingAddressSelection,
            relatedPersonSelect, maglev, offerSource, offerType, expirationDate, netValue,
            currency, offerStatus, equipment, model, outputLanguage, serialNumber, abnormalOrder,
            freightShow, paymentCond, exportPaymentTerm, directForward, directExport,
            customerRequestDate, customerDecisionDate,pssrName;
    private OfferDetail offerDetail;
    private RecyclerView offerProductsRV,rvNotes;
    String offerId;

    String[] yesno;
    BaseService baseService = new BaseService();
    private QuotationDetailResponseBody quotationDetailResponseBody;
    private List<KeyValuePair> noteTypeList = new ArrayList<>();
    private List<KeyValuePair> formTypeList = new ArrayList<>();
    private List<QuotationDetailResponseBody.QuotationDetailOutputData> types;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setContentView(R.layout.activity_md_offer);
        initView();
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        yesno = getResources().getStringArray(R.array.expertise_select_yes_no);
        prpNoteTypes();
        prpFormTypes();
        offerId = getIntent().getStringExtra(MD_OFFER_ID);
        if (offerId != null) {
            fetchDetail(offerId, this::bindView);
        }
    }

    void prpNoteTypes(){
        String[] titles = getResources().getStringArray(R.array.create_offer_note_type_array);
        for(int i = 0 ; i<titles.length ; i++){
            String[] a = titles[i].split("\\|");
            noteTypeList.add(new KeyValuePair(a[0],a[1]));
        }
    }
    void prpFormTypes(){
        String[] titles = getResources().getStringArray(R.array.create_offer_output_types);
        for(int i = 0 ; i<titles.length ; i++){
            String[] a = titles[i].split("\\|");
            formTypeList.add(new KeyValuePair(a[0],a[1]));
        }
    }


    private void fetchDetail(String offerID, Runnable onComplete) {
        showProgressDialog();
        Observable<BaseResponse<OfferDetail>> mdOpportunityCall = baseService.ibs.getMdOfferDetail(baseService.auth, baseService.username, offerID).onErrorResumeNext(Observable.empty());
        Observable<QuotationDetailResponseBody> quotationDetailCall = baseService.ibs.quotationDetail(baseService.auth,baseService.username,offerID).onErrorResumeNext(Observable.empty());

        Disposable disposable = Observable.merge(
                mdOpportunityCall.subscribeOn(Schedulers.io()),
                quotationDetailCall.subscribeOn(Schedulers.io()))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(it -> {
                    if(it != null){
                        if(it.getData() instanceof OfferDetail){
                            offerDetail = (OfferDetail) it.getData();
                        }else if(it instanceof QuotationDetailResponseBody){
                            quotationDetailResponseBody = (QuotationDetailResponseBody) it;
                        }
                    }
                }, throwable -> {
                    //OnError
                    hideProgressDialog();
                    Log.e("Request Error",throwable.getMessage(),throwable);
                }, () -> {
                    //OnComplete
                    hideProgressDialog();
                    onComplete.run();
                    System.out.println("All request Completed");
                });

        addDisposable(disposable);
    }

    private void bindView() {
        CustomerDetailModel customerDetailModel = DataTransfer.getInstance().getData("latestSelectedCustomerDetailModel",CustomerDetailModel.class);
        setTitle(Utility.trimLeadingZeros(offerId));
        CustomerResponse.SingleCustomer customer = DataTransfer.getInstance().getData(DataKeys.LATEST_SELECTED_CUSTOMER, CustomerResponse.SingleCustomer.class);
        if(customer != null){
            customerSelection.setText(customer.getName());
            customerNo.setText(Utility.trimLeadingZeros(customer.getId()));
        }

        if (customerDetailModel != null && customerDetailModel.getAddresses() != null && customerDetailModel.getAddresses().size() > 0) {
            billingAddressSelection.setText(customerDetailModel.getAddresses().get(0).getFormattedAdress());
        }
        if (offerDetail == null) {
            return;
        }
        OfferInfo offerInfo = offerDetail.getOfferInfo();
        if (offerInfo == null) {
            offerInfo = new OfferInfo();
        }

        String contactPerson = "";
        String serialNumberText = "";
        String currencyVal = "";
        List<OfferItem> offerItemList = new ArrayList<>();
        if(quotationDetailResponseBody !=null && quotationDetailResponseBody.getData() != null){
            QuotationDetailResponseBody.QuotationDetailHeader header = quotationDetailResponseBody.getData().header;
            contactPerson = header.contactPersonDescription;
            serialNumberText = header.serialNumber;
            currencyVal = header.currency;
            offerItemList = quotationDetailResponseBody.getData().itemList;
        }

        pssrName.setText(offerInfo.getPssrName());
        relatedPersonSelect.setText(contactPerson);
        maglev.setText(offerInfo.getMaglev());
        offerSource.setText(offerInfo.getOrigin());
        offerType.setText(offerInfo.getOfferPriorityTypeText());
        expirationDate.setText(offerInfo.getValidTo());
        netValue.setText(Utility.getFormattedPrice(offerInfo.getNetValue().toString(),offerInfo.getCurrency()));
        currency.setText(offerInfo.getCurrency());
        offerStatus.setText(offerInfo.getStatus());
        equipment.setText(offerInfo.getEquipmentId());
        model.setText(offerInfo.getModel());
        outputLanguage.setText(offerInfo.getOutputLanguage());
        serialNumber.setText(serialNumberText);
        abnormalOrder.setText(booleanToYesNoString(offerInfo.getIsAbnormal()));
        freightShow.setText(booleanToYesNoString(offerInfo.getIsFreightIncluded()));
        directForward.setText(booleanToYesNoString(offerInfo.getHasDirectShipping()));
        directExport.setText(booleanToYesNoString(offerInfo.getHasDirectExport()));
        customerRequestDate.setText(offerInfo.getCustomerDemandDate());
        customerDecisionDate.setText(offerInfo.getCustomerDecisionDate());
        exportPaymentTerm.setText(String.format("%s - %s", offerInfo.getOutputPaymentTerm(), offerInfo.getOutputPaymentTermText()));
        paymentCond.setText(String.format("%s - %s", offerInfo.getPaymentTerm(), offerInfo.getPaymentTermText()));

        if(offerItemList != null){
            ArrayList<OfferItem> products = new ArrayList<>();
            for (OfferItem product : offerItemList) {
                if(!Utility.trimLeadingZeros(product.getMainItemNumber()).equals("0")){
                    products.add(product);
                }
            }
            OfferProductsAdapter offerProductsAdapter = new OfferProductsAdapter(products,currencyVal);
            offerProductsRV.setAdapter(offerProductsAdapter);
            offerProductsAdapter.notifyDataSetChanged();
        }

        if(offerInfo.getNotes() != null){
            List<Note> noteList = offerInfo.getNotes();
            SimpleListItemRVAdapter<Note> adapter = new SimpleListItemRVAdapter<Note>(this,noteList) {
                @Override
                public void onBindViewHolder(SimpleListItemRVAdapter.MyViewHolder holder, int position) {
                    Note note = this.getItem(position);
                    String noteTitle ="";
                    for(KeyValuePair pair : noteTypeList){
                        if(pair.getKey().equals(note.getName())){
                            noteTitle = pair.getValue();
                        }
                    }
                    holder.getText1().setText(noteTitle);
                    holder.getText2().setText(note.getValue());
                }
            };

            // Bind to our new adapter.
            rvNotes.setAdapter(adapter);
        }
    }

    public String booleanToYesNoString(boolean val) {
        if (yesno == null) {
            return "";
        }
        if (val) {
            return yesno[0];
        } else {
            return yesno[1];
        }
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
            case R.id.print_item:
                showOfferOutputDialog();
                break;

            case R.id.action_text:
                updateOffer();
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Utility.RESPONSE_CODE_GENERAL) {
            if (resultCode == RESULT_OK) {
                recreate();
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.offer_menu, menu);
        //menu.findItem(R.id.action_text).setVisible(false);
        return true;
    }

    private void initView() {
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        pssrName = (TextView) findViewById(R.id.pssr_name);
        customerSelection = (TextView) findViewById(R.id.customer_selection);
        customerNo = (TextView) findViewById(R.id.customer_no);
        billingAddressSelection = (TextView) findViewById(R.id.delivery_address_selection);
        relatedPersonSelect = (TextView) findViewById(R.id.related_person_select);
        maglev = (TextView) findViewById(R.id.maglev);
        offerSource = (TextView) findViewById(R.id.offer_source);
        offerType = (TextView) findViewById(R.id.offer_type);
        expirationDate = (TextView) findViewById(R.id.expiration_date);
        netValue = (TextView) findViewById(R.id.net_value);
        currency = (TextView) findViewById(R.id.currency);
        offerStatus = (TextView) findViewById(R.id.offer_status);
        equipment = (TextView) findViewById(R.id.equipment);
        model = (TextView) findViewById(R.id.model);
        outputLanguage = (TextView) findViewById(R.id.output_language);
        serialNumber = (TextView) findViewById(R.id.serial_number);
        abnormalOrder = (TextView) findViewById(R.id.abnormal_order);
        freightShow = (TextView) findViewById(R.id.freight_show);
        directForward = (TextView) findViewById(R.id.direct_dispatch);
        directExport = (TextView) findViewById(R.id.direct_export);
        customerRequestDate = (TextView) findViewById(R.id.customer_request_date);
        customerDecisionDate = (TextView) findViewById(R.id.customer_decision_date);
        paymentCond = (TextView) findViewById(R.id.payment_cond);
        exportPaymentTerm = (TextView) findViewById(R.id.export_payment_term);
        offerProductsRV = findViewById(R.id.offer_product_rv);
        offerProductsRV.setLayoutManager(new LinearLayoutManager(this));
        rvNotes = findViewById(R.id.rv_notes);
        rvNotes.setLayoutManager(new LinearLayoutManager(this));
    }

    public void updateOffer(){
        if(quotationDetailResponseBody != null){
            if(quotationDetailResponseBody.getData() != null ){
                CreateOfferRequestBody form = quotationDetailResponseBody.toCreateOfferRequestBody();
                form.setIsUpdate(true);
                Intent i = new Intent(this, CreateOfferActivity.class);
                i.putExtra("customerID",customerNo.getText());
                i.putExtra("customerName", customerSelection.getText());
                i.putExtra("requestBody", form);
                startActivityForResult(i,Utility.RESPONSE_CODE_GENERAL);
            }else {
                Toast.makeText(MdOfferActivity.this,quotationDetailResponseBody.messagesToString(),Toast.LENGTH_SHORT).show();
            }
        }else{
            Toast.makeText(MdOfferActivity.this,getString(R.string.new_service_demand_error),Toast.LENGTH_SHORT).show();
        }

    }

    public void showOfferOutputDialog(){
        final Dialog dialog = new Dialog(this);
        dialog.setContentView(R.layout.dialog_language_select);
        TextView textView = dialog.findViewById(R.id.title);
        textView.setText(R.string.please_select);
        ListView listview = (ListView) dialog.findViewById(R.id.List);

        if(quotationDetailResponseBody != null && quotationDetailResponseBody.getData() != null && quotationDetailResponseBody.getData().header != null && quotationDetailResponseBody.getData().header.outputData != null) {
            types = quotationDetailResponseBody.getData().header.outputData;
            if(types != null) {
                List<Object> typeNames = types.stream().map(QuotationDetailResponseBody.QuotationDetailOutputData::getText).collect(Collectors.toList());
                ArrayAdapter<Object> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, typeNames);
                listview.setAdapter(adapter);
            }
        } else {
            types = new ArrayList<>();
        }

        listview.setOnItemClickListener((parent, view, position, id) -> {
            showProgressDialog();
            String formType = types.get(position).getForm();
            Disposable disposable = baseService.ibs.quotationOutput(baseService.auth,baseService.username,offerId,formType)
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeOn(Schedulers.io())
                    .subscribe(response -> {
                        if(response !=  null){
                            if(response.getData() != null&& response.getData().getFileContent() != null && response.getData().getFileContent().size() > 0){
                                QuotationOutput.FileContent fileContent = response.getData().getFileContent().get(0);
                                String rootDir = Environment.getExternalStorageDirectory() + "/Sniper/Quotation Output";
                                checkAndCreateDirectory(rootDir);
                                String filename = new StringBuilder()
                                        .append(rootDir)
                                        .append("/")
                                        .append(offerId)
                                        .append("_")
                                        .append(fileContent.getFormText())
                                        .append(".pdf").toString();

                                byte[] pdfData = Base64.decode(fileContent.getBinaryData(), Base64.DEFAULT);
                                if(pdfData != null){
                                    File file = new File(filename);
                                    FileOutputStream fs = new FileOutputStream(file, false);
                                    fs.write(pdfData);
                                    fs.flush();
                                    fs.close();
                                    Utility.openFile(file,this);
                                }

                            }else{
                                Toast.makeText(MdOfferActivity.this,response.messagesToString(),Toast.LENGTH_SHORT).show();
                            }
                        }
                        hideProgressDialog();
                    },error -> {
                        hideProgressDialog();
                        Log.e("MD_OFFER_ACTIVITY", error.getMessage(), error);
                    });
            addDisposable(disposable);
            dialog.dismiss();
        });
        dialog.show();
    }

    private void checkAndCreateDirectory(String dirName) {
        File new_dir = new File(dirName);
        if (!new_dir.exists()) {
            new_dir.mkdirs();
        }
    }


}
