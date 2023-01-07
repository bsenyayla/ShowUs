package com.san.sniper.activities;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.san.sniper.CreateOffer.adapters.EditNotesAdapter;
import com.san.sniper.LogConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.adapters.QuotationAttachmentAdapter;
import com.san.sniper.adapters.QuotationProductListAdapter;
import com.san.sniper.enums.ServiceQuotationStatus;
import com.san.sniper.requestpojos.QuotationNoteRequest;
import com.san.sniper.requestpojos.ServiceQuotationUpdateRequest;
import com.san.sniper.requestpojos.quotation.OfferNote;
import com.san.sniper.responsepojos.checkin.KeyValuePair;
import com.san.sniper.responsepojos.servicequotation.QuotationAttachment;
import com.san.sniper.responsepojos.servicequotation.ServiceQuotation;
import com.san.sniper.responsepojos.servicequotation.ServiceQuotationDetail;
import com.san.sniper.responsepojos.servicequotation.ServiceQuotationNote;
import com.san.sniper.responsepojos.servicequotation.ServiceQuotationOutput;
import com.san.sniper.service.QuotationService;
import com.san.sniper.views.LabelledSpinner;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint("NonConstantResourceId")
public class ServiceQuotationDetailActivity extends BaseActivity {

    @BindView(R.id.text_soa_detail_offer_no)
    TextView tvOfferNo;
    @BindView(R.id.text_soa_detail_description)
    TextView tvDescription;
    @BindView(R.id.text_soa_detail_customer_name)
    TextView tvCustomerName;
    @BindView(R.id.text_soa_detail_related_person)
    TextView tvRelatedPerson;
    @BindView(R.id.text_soa_detail_workorder_no)
    TextView tvWorkOrderNo;
    @BindView(R.id.text_soa_detail_status)
    TextView tvStatus;
    @BindView(R.id.text_soa_detail_net_value)
    TextView tvNetValue;
    @BindView(R.id.text_soa_detail_requested_beginning)
    TextView tvRequestedBeginning;
    @BindView(R.id.text_soa_detail_requested_finish)
    TextView tvRequestedFinish;
    @BindView(R.id.text_soa_detail_main_offer_check)
    TextView tvMainOfferCheck;

    @BindView(R.id.text_soa_detail_equipment_model)
    TextView tvEquipmentModel;
    @BindView(R.id.text_soa_detail_equipment_serial)
    TextView tvEquipmentSerial;
    @BindView(R.id.text_soa_detail_equipment_workinghour)
    TextView tvEquipmentWorkingHour;
    @BindView(R.id.text_soa_detail_equipment_counter)
    TextView tvEquipmentCounter;
    @BindView(R.id.text_soa_detail_credit_status)
    TextView tvEquipmentCreditStatus;

    @BindView(R.id.recycler_soa_items)
    RecyclerView rvItems;
    @BindView(R.id.recycler_soa_notes)
    RecyclerView rvNotes;
    @BindView(R.id.addNoteBtn)
    FloatingActionButton addNoteBtn;

    @BindView(R.id.text_soa_detail_orgunit)
    TextView tvOrganizationUnit;
    @BindView(R.id.text_soa_detail_org)
    TextView tvOrganization;
    @BindView(R.id.text_soa_detail_distribution)
    TextView tvDistribution;
    @BindView(R.id.text_soa_detail_section)
    TextView tvSection;
    @BindView(R.id.text_soa_detail_saleoffice)
    TextView tvSaleOffice;
    @BindView(R.id.text_soa_detail_service_unit)
    TextView tvServiceUnit;
    @BindView(R.id.text_soa_detail_service_org)
    TextView tvServiceOrganization;

    @BindView(R.id.text_soa_detail_paymentopt)
    TextView tvPaymentOptions;
    @BindView(R.id.text_soa_detail_payer)
    TextView tvPayer;
    @BindView(R.id.text_soa_detail_billacceptor)
    TextView tvBillAcceptor;
    @BindView(R.id.text_soa_detail_billing_credit_status)
    TextView tvBillingCreditStatus;

    @BindView(R.id.button_soa_print)
    ImageButton btnSoaPrint;
    @BindView(R.id.button_soa_attachments)
    ImageButton btnSoaAttachment;
    @BindView(R.id.button_soa_reject)
    Button btnSoaReject;
    @BindView(R.id.button_soa_approve)
    Button btnSoaApprove;

    @BindView(R.id.button_update)
    Button btnUpdate;

    private String currentQuotationId;
    private QuotationService quotationService;
    private ServiceQuotationDetail serviceQuotationDetail;
    private boolean isCrudAvailable;
    private String selectedUsername;
    private ServiceQuotationUpdateRequest serviceQuotationUpdateRequest;
    private QuotationProductListAdapter quotationProductListAdapter;
    private EditNotesAdapter notesAdapter;

    public static Intent newIntent(Context context, String quotationId, boolean isCrudAvailable, String selectedUsername) {
        Intent intent = new Intent(context, ServiceQuotationDetailActivity.class);
        intent.putExtra("quotationId", quotationId);
        intent.putExtra("isCrudAvailable", isCrudAvailable);
        intent.putExtra("selectedUsername", selectedUsername);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setContentView(R.layout.activity_service_quotation_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ButterKnife.bind(this);

        quotationService = new QuotationService();
        notesAdapter = new EditNotesAdapter(this);
        serviceQuotationUpdateRequest = new ServiceQuotationUpdateRequest();

        Intent intent = getIntent();
        if (intent != null && intent.getExtras() != null) {
            currentQuotationId = intent.getExtras().getString("quotationId", "");
            isCrudAvailable = intent.getExtras().getBoolean("isCrudAvailable", false);
            selectedUsername = intent.getExtras().getString("selectedUsername", "");
        }

        initializeRecyclerView();
        fetchServiceQuotationDetail();
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initializeRecyclerView() {
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        quotationProductListAdapter = new QuotationProductListAdapter();
        rvItems.setLayoutManager(linearLayoutManager);
        rvItems.setAdapter(quotationProductListAdapter);
        rvItems.setOnTouchListener((v, event) -> {
            hideKeyboard(this);
            return false;
        });
    }

    private void fetchServiceQuotationDetail() {
        showProgressDialog();
        quotationService.getServiceQuotationDetail(currentQuotationId, (result, t) -> {
            if(result != null) {
                serviceQuotationDetail = result;
                setupView();
            } else {
                onBackPressed();
            }
            hideProgressDialog();
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void setupView() {
        String trimmedZeros = Utility.trimLeadingZeros(serviceQuotationDetail.getObjectId());
        setTitle(trimmedZeros);

        tvOfferNo.setText(serviceQuotationDetail.getObjectId());
        tvDescription.setText(serviceQuotationDetail.getDescription());
        tvCustomerName.setText(serviceQuotationDetail.getCustomerName());
        tvRelatedPerson.setText(getString(R.string.catapult_empty_value));
        tvWorkOrderNo.setText(serviceQuotationDetail.getWorkOrder());
        tvStatus.setText(serviceQuotationDetail.getStatusText());
        tvNetValue.setText(serviceQuotationDetail.getNetValue() + " " + serviceQuotationDetail.getCurrency());
        tvRequestedBeginning.setText(serviceQuotationDetail.getValidFrom());
        tvRequestedFinish.setText(serviceQuotationDetail.getValidTo());
        tvMainOfferCheck.setText(serviceQuotationDetail.getMainQuotation().equals("X") ? getString(R.string.dialog_yes) : getString(R.string.dialog_no));
        //Notes

        tvEquipmentModel.setText(getString(R.string.catapult_empty_value));
        tvEquipmentSerial.setText(serviceQuotationDetail.getEquipmentSerialNumber());
        tvEquipmentWorkingHour.setText(getString(R.string.catapult_empty_value));
        tvEquipmentCounter.setText(getString(R.string.catapult_empty_value));
        tvEquipmentCreditStatus.setText(getString(R.string.catapult_empty_value));
        //Items List

        tvOrganizationUnit.setText(serviceQuotationDetail.getSalesOrgResp());
        tvOrganization.setText(serviceQuotationDetail.getSalesOrgShort());
        tvDistribution.setText(serviceQuotationDetail.getDisChannel());
        tvSection.setText(serviceQuotationDetail.getDivision());
        tvSaleOffice.setText(serviceQuotationDetail.getSalesOffice());
        tvServiceUnit.setText(serviceQuotationDetail.getSalesOrgRespShort());
        tvServiceOrganization.setText(serviceQuotationDetail.getServiceOrgRespShort());

        tvPaymentOptions.setText(serviceQuotationDetail.getPaymentTermsText());
        tvPayer.setText(getString(R.string.catapult_empty_value));
        tvBillAcceptor.setText(getString(R.string.catapult_empty_value));
        tvBillingCreditStatus.setText(getString(R.string.catapult_empty_value));

        btnSoaApprove.setOnClickListener(v -> onApproveClicked());
        btnSoaReject.setOnClickListener(v -> onRejectClicked());
        btnSoaPrint.setOnClickListener(v -> showQuotationOutputDialog(serviceQuotationDetail));
        btnSoaAttachment.setOnClickListener(v -> onShowAttachmentsClicked());

        if(serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.APPROVED.getValue()) || serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.INVOICEAPPROVED.getValue())) {
            tvStatus.setTextColor(ContextCompat.getColor(this, R.color.stock_item_count));
        }

        quotationProductListAdapter.setProducts(serviceQuotationDetail.getItems());
        quotationProductListAdapter.notifyDataSetChanged();

        addNoteBtn.setOnClickListener(v -> notesAdapter.addItem());
        ArrayList<OfferNote> noteList = new ArrayList<>();
        for(ServiceQuotationNote note : serviceQuotationDetail.getNotes()) {
            noteList.add(new OfferNote(note.getTdId(), note.getText().trim().replace("\n", "").replace("\r", "")));
        }

        notesAdapter.setNoteList(noteList);
        rvNotes.setAdapter(notesAdapter);
        rvNotes.setLayoutManager(new LinearLayoutManager(this));
        notesAdapter.notifyDataSetChanged();
        btnUpdate.setOnClickListener(v -> checkIfAnyUpdatedNote());

        if(!isCrudAvailable) {
            btnSoaApprove.setVisibility(View.GONE);
            btnSoaReject.setVisibility(View.GONE);
        } else {
            if(serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.REJECTED.getValue()) || serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.INVOICEREJECTED.getValue()) || serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.APPROVED.getValue()) || serviceQuotationDetail.getStatus().equals(ServiceQuotationStatus.INVOICEAPPROVED.getValue())) {
                btnSoaApprove.setVisibility(View.GONE);
                btnSoaReject.setVisibility(View.GONE);
            } else {
                btnSoaApprove.setVisibility(View.VISIBLE);
                btnSoaReject.setVisibility(View.VISIBLE);
            }
        }
    }

    private String getCorrectStatusFromStatus(String statusText, boolean isApproved) {
        String validStatus = "";
        if(isApproved) {
            if(statusText.equals(ServiceQuotationStatus.ONPSSR.getValue())) {
                validStatus = ServiceQuotationStatus.APPROVED.getValue();
            } else if(statusText.equals(ServiceQuotationStatus.WAITINGFORBILLINGAPRROVAL.getValue())) {
                validStatus = ServiceQuotationStatus.INVOICEAPPROVED.getValue();
            }
        } else {
            if(statusText.equals(ServiceQuotationStatus.ONPSSR.getValue())) {
                validStatus = ServiceQuotationStatus.REJECTED.getValue();
            } else if(statusText.equals(ServiceQuotationStatus.WAITINGFORBILLINGAPRROVAL.getValue())) {
                validStatus = ServiceQuotationStatus.INVOICEREJECTED.getValue();
            }
        }

        return validStatus;
    }

    private void checkIfAnyUpdatedNote() {
        ArrayList<QuotationNoteRequest> editedNotes = new ArrayList<>();

        for (OfferNote note: notesAdapter.getNoteList()) {
            QuotationNoteRequest updatedNote = new QuotationNoteRequest(note.getNoteType(), note.getNoteText());
            editedNotes.add(updatedNote);
        }

        if(serviceQuotationDetail.getNotes().size() > editedNotes.size()) {
            for (ServiceQuotationNote serviceNote: serviceQuotationDetail.getNotes()) {
                QuotationNoteRequest updatedNote = new QuotationNoteRequest(serviceNote.getTdId(), "");
                editedNotes.add(updatedNote);
            }
        }

        serviceQuotationUpdateRequest.setStatus(serviceQuotationDetail.getStatus());
        serviceQuotationUpdateRequest.setNotes(editedNotes);
        updateServiceQuotation(serviceQuotationDetail, false, false);
    }

    private void updateServiceQuotation(ServiceQuotationDetail serviceQuotation, boolean isApproved, boolean isShiftStatus) {
        if(isShiftStatus) {
            String shiftedStatus = getCorrectStatusFromStatus(serviceQuotation.getStatus(), isApproved);
            serviceQuotationUpdateRequest.setStatus(shiftedStatus);
        }

        showProgressDialog();
        quotationService.updateServiceQuotation(serviceQuotation.getObjectId(), serviceQuotationUpdateRequest, (result, t) -> {
            if(result != null) {
                Toast.makeText(this, getString(R.string.update_successfully), Toast.LENGTH_SHORT).show();
                if(isShiftStatus) {
                    String logInfo = isApproved ? "Approved" : "Rejected";
                    Utility.logUsage(LogConstants.Section.SERVICE_QUOTATION_APPROVAL, LogConstants.Activity.PSSR_APPROVAL, serviceQuotation.getObjectId() +"/" +logInfo);
                }
                fetchServiceQuotationDetail();
            } else {
                Toast.makeText(this, getString(R.string.update_not_successfully), Toast.LENGTH_LONG).show();
            }
            hideProgressDialog();
        });
    }

    public void onApproveClicked() {
        String message = getString(R.string.soa_approve_dialog, serviceQuotationDetail.getCustomer(), serviceQuotationDetail.getObjectId());
        showApproveDialog(serviceQuotationDetail, message, true);
    }

    public void onRejectClicked() {
        String message = getString(R.string.soa_reject_dialog, serviceQuotationDetail.getCustomer(), serviceQuotationDetail.getObjectId());
        showApproveDialog(serviceQuotationDetail, message, false);
    }

    private void showApproveDialog(ServiceQuotationDetail serviceQuotation, String message, boolean isApproved) {
        AlertDialog alertDialog = new AlertDialog.Builder(this)
                .setCancelable(true)
                .setTitle(R.string.title_warning)
                .setMessage(message)
                .setPositiveButton(R.string.dialog_yes, (dialog, which) -> {
                    checkIfNeedAttachToAnyNote(serviceQuotation, isApproved);
                })
                .setNegativeButton(R.string.dialog_no,null)
                .create();

        alertDialog.show();
    }

    private void checkIfNeedAttachToAnyNote(ServiceQuotationDetail serviceQuotation, boolean isApproved) {
        String[] titles = getResources().getStringArray(R.array.create_offer_note_type_array);
        List<KeyValuePair> noteTypeList = new ArrayList<>();

        for (String title : titles) {
            String[] a = title.split("\\|");
            noteTypeList.add(new KeyValuePair(a[0], a[1]));
        }

        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle(R.string.lbl_note);

        final View view = LayoutInflater.from(this).inflate(R.layout.dialog_add_note, null);
        final LabelledSpinner noteTitleSpinner = view.findViewById(R.id.note_title_spinner);
        noteTitleSpinner.setData(noteTypeList);

        final EditText input = view.findViewById(R.id.note_edit_text);
        alertDialog.setView(view);

        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, getString(R.string.ok), (dialog, which) -> {
            dialog.cancel();
            if(input.getText() != null && !input.getText().toString().isEmpty()) {
                ArrayList<QuotationNoteRequest> notes = new ArrayList<>();
                KeyValuePair pair = noteTitleSpinner.getSelectedItem(KeyValuePair.class);
                QuotationNoteRequest note = new QuotationNoteRequest(pair.getKey(), input.getText().toString());
                notes.add(note);
                serviceQuotationUpdateRequest.setNotes(notes);
            }
            updateServiceQuotation(serviceQuotation, isApproved, true);
        });

        alertDialog.setButton(AlertDialog.BUTTON_NEGATIVE, getString(R.string.cancel), (dialog, which) -> {
            dialog.cancel();
        });

        alertDialog.show();
    }

    public void onShowAttachmentsClicked() {
        showProgressDialog();
        quotationService.getServiceQuotationAttachments(selectedUsername, serviceQuotationDetail.getObjectId(), (result, t) -> {
            if(result != null && result.size() > 0) {
                showAttachmentsDialog(serviceQuotationDetail.getObjectId(), result);
            } else {
                Toast.makeText(this, R.string.soa_no_document_message, Toast.LENGTH_LONG).show();
            }
            hideProgressDialog();
        });
    }

    private void showAttachmentsDialog(String quotationId, ArrayList<QuotationAttachment> attachments) {
        final Dialog dialog = new Dialog(this);
        dialog.setContentView(R.layout.dialog_language_select);
        TextView textView = dialog.findViewById(R.id.title);
        textView.setText(R.string.soa_attahments_dialog_title);
        ListView listview = dialog.findViewById(R.id.List);

        if(attachments != null) {
            QuotationAttachmentAdapter adapter = new QuotationAttachmentAdapter(this, attachments);
            adapter.setCallback((document, t) -> {
                dialog.dismiss();
                showProgressDialog();
                String documentId = document.getFileId();

                quotationService.getServiceQuotationDocument(selectedUsername, quotationId, documentId, (result, error) -> {
                    if(result != null) {
                        String rootDir = Environment.getExternalStorageDirectory() + "/Sniper/Quotation Document";
                        checkAndCreateDirectory(rootDir);

                        String filename = new StringBuilder()
                                .append(rootDir)
                                .append("/")
                                .append(quotationId)
                                .append("_")
                                .append(Utility.getFileName(result.getFileName()))
                                .append("." + result.getFileName().substring(result.getFileName().indexOf(".") + 1)).toString();

                        byte[] documentData = Base64.decode(result.getContent(), Base64.DEFAULT);
                        if(documentData != null) {
                            try {
                                File file = new File(filename);
                                FileOutputStream fs = new FileOutputStream(file, false);
                                fs.write(documentData);
                                fs.flush();
                                fs.close();
                                Utility.openFile(file, this);
                            } catch (IOException e) {
                                Toast.makeText(this, getString(R.string.catapult_error_message), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                    hideProgressDialog();
                });
            });

            listview.setAdapter(adapter);
        }

        dialog.show();
    }

    private void showQuotationOutputDialog(ServiceQuotationDetail serviceQuotationDetail) {
        final Dialog dialog = new Dialog(this);
        dialog.setContentView(R.layout.dialog_language_select);
        TextView textView = dialog.findViewById(R.id.title);
        textView.setText(R.string.soa_offer_print_options_dialog_title);
        ListView listview = dialog.findViewById(R.id.List);

        if(serviceQuotationDetail.getOutputDatas() != null) {
            List<Object> typeNames = serviceQuotationDetail.getOutputDatas().stream().map(ServiceQuotationOutput::getText).collect(Collectors.toList());
            ArrayAdapter<Object> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, typeNames);
            listview.setAdapter(adapter);
        }

        listview.setOnItemClickListener((parent, view, position, id) -> {
            dialog.dismiss();
            showProgressDialog();
            String formType = serviceQuotationDetail.getOutputDatas().get(position).getForm();

            quotationService.getServiceQuotationOutputData(selectedUsername, serviceQuotationDetail.getObjectId(), formType, (result, t) -> {
                String rootDir = Environment.getExternalStorageDirectory() + "/Sniper/Quotation Output";
                checkAndCreateDirectory(rootDir);

                String filename = new StringBuilder()
                        .append(rootDir)
                        .append("/")
                        .append(serviceQuotationDetail.getObjectId())
                        .append("_")
                        .append(result.getFormText())
                        .append(".pdf").toString();

                byte[] pdfData = Base64.decode(result.getBinaryData(), Base64.DEFAULT);
                if(pdfData != null) {
                    try {
                        File file = new File(filename);
                        FileOutputStream fs = new FileOutputStream(file, false);
                        fs.write(pdfData);
                        fs.flush();
                        fs.close();
                        Utility.openFile(file,this);
                    } catch (IOException e) {
                        Toast.makeText(this, getString(R.string.catapult_error_message), Toast.LENGTH_SHORT).show();
                    }
                }

                hideProgressDialog();
            });
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
