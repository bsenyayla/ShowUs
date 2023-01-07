package com.san.sniper.activities;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Geocoder;
import android.os.Bundle;
import android.text.InputFilter;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.san.sniper.AppConstants;
import com.san.sniper.DataKeys;
import com.san.sniper.Filter.LatinInputFilter;
import com.san.sniper.LogConstants;
import com.san.sniper.R;
import com.san.sniper.Utility;
import com.san.sniper.builders.RetrofitBuilder;
import com.san.sniper.interfaces.IsanServices;
import com.san.sniper.responsepojos.BaseResponse;
import com.san.sniper.responsepojos.customer.Address;
import com.san.sniper.service.BaseService;
import com.san.sniper.singletons.DataTransfer;
import com.san.sniper.singletons.SniperUser;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.schibstedspain.leku.LocationPickerActivity;
import com.schibstedspain.leku.LocationPickerActivityKt;

import java.io.IOException;
import java.util.List;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class CustomerAdressMapsActivity extends BaseActivity implements OnMapReadyCallback {
    private GoogleMap mMap;
    Address customerAdress;
    EditText edtStreet, edtDistrict, edtCountry, edtCity, edtNotes;
    LinearLayout AdressContent, NoteContent;
    Button tab_notes, tab_adress, btnUpdate, btnUpdateNote;
    String customerName;
    private int PLACE_PICKER_REQUEST = 1;
    Button btnUpdateLocation;
    boolean isNewAddress = false;
    String customerID = "";
    boolean isCrudAvailable = false;
    BaseService baseService = new BaseService();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_customer_adress_maps);
        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        edtStreet = (EditText) findViewById(R.id.edtStreet);
        edtDistrict = (EditText) findViewById(R.id.edtDistrict);
        edtCountry = (EditText) findViewById(R.id.edtCountry);
        edtCity = (EditText) findViewById(R.id.edtCity);
        edtNotes = (EditText) findViewById(R.id.edtNotes);
        AdressContent = (LinearLayout) findViewById(R.id.AdressContent);
        NoteContent = (LinearLayout) findViewById(R.id.NoteContent);
        tab_adress = (Button) findViewById(R.id.tab_adress);
        tab_notes = (Button) findViewById(R.id.tab_notes);
        btnUpdate = (Button) findViewById(R.id.btnUpdate);
        btnUpdateNote = (Button) findViewById(R.id.btnUpdateNote);
        btnUpdateLocation = (Button) findViewById(R.id.btnUpdateLocation);

        Intent i = getIntent();
        customerName = i.getExtras().getString("customerName", "");
        customerAdress = (Address) i.getSerializableExtra("customerAdress");
        boolean openAddressPicker = i.getBooleanExtra("openAddressPicker", false);
        isCrudAvailable = i.getBooleanExtra("isCrudAvailable", false);
        getSupportActionBar().setTitle(customerName);

        edtStreet.setFilters(new InputFilter[]{new LatinInputFilter()});
        edtDistrict.setFilters(new InputFilter[]{new LatinInputFilter()});
        edtCity.setFilters(new InputFilter[]{new LatinInputFilter()});
        edtCountry.setFilters(new InputFilter[]{new LatinInputFilter()});
        edtNotes.setFilters(new InputFilter[]{new LatinInputFilter()});

        if (!SniperUser.getInstance().permissions.contains(AppConstants.User.Permission.CUSTOMER_ADDRESS_EDIT)) {
            btnUpdate.setVisibility(View.GONE);
            btnUpdateLocation.setVisibility(View.GONE);
            TextView tv = findViewById(R.id.txtIsBilling);
            if (tv != null) {
                tv.setVisibility(View.GONE);
            }
        }



        if (customerAdress != null) {

            getSupportActionBar().setTitle(customerName + "/" + customerAdress.getCity());
            checkAdressLatLng();
            setvalues();
        } else {
            isNewAddress = true;
            btnUpdate.setText(getResources().getText(R.string.btn_add_adress));
            customerID = i.getExtras().getString("customerID", "");
            activateLocationSelect();
        }


        btnUpdate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!isCrudAvailable) {
                    showCrudOperationInfoDialog();
                    return;
                }

                if (customerAdress != null) {
                    updateValues();
                } else {
                    Toast.makeText(getApplicationContext(), getString(R.string.select_location), Toast.LENGTH_SHORT).show();
                }

            }
        });
        btnUpdateNote.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!isCrudAvailable) {
                    showCrudOperationInfoDialog();
                    return;
                }

                updateValues();
            }
        });

        tab_adress.setAlpha(0.5f);
        tab_notes.setAlpha(1);


        tab_adress.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AdressContent.setVisibility(View.VISIBLE);
                NoteContent.setVisibility(View.GONE);
                tab_adress.setAlpha(0.5f);
                tab_notes.setAlpha(1);


            }
        });
        tab_notes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                NoteContent.setVisibility(View.VISIBLE);
                AdressContent.setVisibility(View.GONE);
                tab_notes.setAlpha(0.5f);
                tab_adress.setAlpha(1);
            }
        });


        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
        if (openAddressPicker) {
            showPlacePicker();
        }
    }


    private void activateLocationSelect() {
        if (SniperUser.getInstance().permissions.contains(AppConstants.User.Permission.CUSTOMER_ADDRESS_EDIT)) {
            btnUpdateLocation.setVisibility(View.VISIBLE);
            btnUpdateLocation.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!isCrudAvailable) {
                        showCrudOperationInfoDialog();
                        return;
                    }
                    showPlacePicker();


                }
            });
        }
    }

    public void setvalues() {
        edtStreet.setText(customerAdress.getStreet());
        edtDistrict.setText(customerAdress.getDistrict());
        edtCountry.setText(customerAdress.getCountry());
        edtCity.setText(customerAdress.getCity());
        edtNotes.setText(customerAdress.getNote());

        if (customerAdress.getIsBillAddress()) {
            ((TextView) findViewById(R.id.txtIsBilling)).setText(getString(R.string.billing_adress_cannot_update));
            disableViews(edtStreet, edtDistrict, edtCountry, edtCity, btnUpdate, btnUpdateLocation);

        } else {

            activateLocationSelect();
        }
    }

    private void checkAdressLatLng() {
        if (customerAdress.getLatitude() == 0.0 && customerAdress.getLongitude() == 0.0)
            prpAlert();
    }

    private void prpAlert() {

        String msg = getString(R.string.customer_lat_lng_not_found2);
        if (customerAdress.getIsBillAddress()) {
            msg = getString(R.string.customer_lat_lng_not_found);
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(customerName)
                .setMessage(msg)
                .setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // continue with delete
                        dialog.dismiss();
                    }
                })
                .show();
    }


    private void updateValues() {

        String City = edtCity.getText().toString();
        String District = edtDistrict.getText().toString();//mahalle
        String Street = edtStreet.getText().toString();
        String Country = edtCountry.getText().toString();
        String Note = edtNotes.getText().toString();

        Retrofit retrofit = RetrofitBuilder.getRetrofit(getApplication());
        IsanServices ibs = retrofit.create(IsanServices.class);

        showProgressDialog();

        DataTransfer.getInstance().removeData(DataKeys.ACTIVITY_ADDRESSES); // Refresh Check-In addresses data

        if (isNewAddress) {
            Call<BaseResponse<Object>> call = ibs.
                    AddNewCustomerAdress(baseService.auth, baseService.username,
                            customerID, City, District, Street, false, Country,
                            customerAdress.getLongitude(), customerAdress.getLatitude(), "", Note, "SHIP_TO");
            call.enqueue(new Callback<BaseResponse<Object>>() {
                @Override
                public void onResponse(Call<BaseResponse<Object>> call, Response<BaseResponse<Object>> response) {
                    hideProgressDialog();

                    BaseResponse<Object> responseBody = response.body();
                    if (responseBody != null && responseBody.isSuccessful()) {
                        Toast.makeText(getApplicationContext(), getString(R.string.adress_added_successfully), Toast.LENGTH_SHORT).show();
                        successfullyUpdated();
                    } else if (responseBody != null) {
                        responseBody.showMessages(getApplicationContext());
                    } else {
                        Toast.makeText(getApplicationContext(), getString(R.string.update_not_successfully), Toast.LENGTH_LONG).show();
                    }

                }

                @Override
                public void onFailure(Call<BaseResponse<Object>> call, Throwable t) {
                    hideProgressDialog();
                    Toast.makeText(getApplicationContext(), getString(R.string.update_not_successfully), Toast.LENGTH_SHORT).show();

                }
            });
        } else {

            Call<BaseResponse<Object>> call = ibs.
                    CustomerEditAddress(baseService.auth, baseService.username,
                            customerAdress.getCustomerId(), City, District, Street, customerAdress.getIsBillAddress(), Country,
                            customerAdress.getLongitude(), customerAdress.getLatitude(), customerAdress.getId(), Note, "SHIP_TO");
            call.enqueue(new Callback<BaseResponse<Object>>() {
                @Override
                public void onResponse(Call<BaseResponse<Object>> call, Response<BaseResponse<Object>> response) {
                    hideProgressDialog();
                    BaseResponse<Object> responseBody = response.body();
                    if (responseBody != null && responseBody.isSuccessful()) {
                        Toast.makeText(getApplicationContext(), getString(R.string.update_successfully), Toast.LENGTH_SHORT).show();
                        successfullyUpdated();
                    } else if (responseBody != null) {
                        response.body().showMessages(getApplicationContext());
                    } else {
                        Toast.makeText(getApplicationContext(), getString(R.string.update_not_successfully), Toast.LENGTH_LONG).show();
                    }

                }

                @Override
                public void onFailure(Call<BaseResponse<Object>> call, Throwable t) {
                    hideProgressDialog();
                    Toast.makeText(getApplicationContext(), getString(R.string.update_not_successfully), Toast.LENGTH_SHORT).show();

                }
            });
        }

    }

    private void successfullyUpdated() {
        Intent returnIntent = new Intent();
        setResult(Activity.RESULT_OK, returnIntent);
        finish();
    }


    public void disableViews(View... edtText) {
        for (View mView : edtText) {
            mView.setEnabled(false);
        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);

    }

    private void showPlacePicker() {

        Intent locationPickerIntent = new LocationPickerActivity.Builder()
                .withGeolocApiKey(getString(R.string.google_maps_key))
                .withSatelliteViewHidden()
                .withVoiceSearchHidden()
                .build(this);

        startActivityForResult(locationPickerIntent, PLACE_PICKER_REQUEST);


    }



    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == PLACE_PICKER_REQUEST) {
            if (resultCode == RESULT_OK) {

                if (isNewAddress)
                    customerAdress = new Address();

                double latitude = data.getDoubleExtra(LocationPickerActivityKt.LATITUDE, 0.0);
                double longitude = data.getDoubleExtra(LocationPickerActivityKt.LONGITUDE, 0.0);


                Geocoder geocoder = new Geocoder(this);
                try {
                    List<android.location.Address> addresses =
                            geocoder.getFromLocation
                       (latitude, longitude, 1);

                    android.location.Address madress = addresses.get(0);

                    String contry = getValues(madress.getCountryCode());
                    String city = getValues(madress.getAdminArea());// İl
                    String district = getValues(madress.getSubAdminArea()); // İlçe
                    //Mahalle sokak no
                    String street = (getValues(madress.getLocality()) + " " + getValues(madress.getSubLocality()) + " , " + getValues(madress.getThoroughfare()) + " " + getValues(madress.getSubThoroughfare())).trim();
                    edtCountry.setText(contry);
                    edtCity.setText(city);
                    edtDistrict.setText(district);
                    edtStreet.setText(street);
                    customerAdress.setLatitude(latitude);
                    customerAdress.setLongitude(longitude);

                    // {customerID}/{street}/{district}/{city}/{country}
                    String attachedInfo = new StringBuilder()
                            .append(customerID)
                            .append("/")
                            .append(street)
                            .append("/")
                            .append(district)
                            .append("/")
                            .append(city)
                            .append("/")
                            .append(contry)
                            .toString();
                    if (isNewAddress) {
                        Utility.logUsage(LogConstants.Section.CUSTOMER, LogConstants.Activity.ADD_CUSTOMER_LOCATION, attachedInfo);
                    } else {
                        Utility.logUsage(LogConstants.Section.CUSTOMER, LogConstants.Activity.UPDATE_CUSTOMER_LOCATION, attachedInfo);
                    }

                } catch (IOException e) {

                } catch (IndexOutOfBoundsException e) {
                    //madress is empty
                }

                LatLng latLng = new LatLng(latitude,longitude);
                mMap.clear();
                mMap.addMarker(new MarkerOptions().position(latLng).title(customerName));
                moveToCurrentLocation(latLng);
            }
        }
    }

    public String getValues(String value) {

        String result = "";
        if (!"".equals(value) && null != value) {
            result = value;
        }
        return result;
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;

        // Add a marker in Sydney and move the camera
        if (customerAdress != null) {
            LatLng adress = new LatLng(customerAdress.getLatitude(), customerAdress.getLongitude());
            Marker marker = mMap.addMarker(new MarkerOptions().position(adress).title(customerName));
            mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(marker.getPosition(), 12f));

        }


    }

    private void moveToCurrentLocation(LatLng currentLocation) {
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLocation, 25));
        // Zoom in, animating the camera.
        mMap.animateCamera(CameraUpdateFactory.zoomIn());
        // Zoom out to zoom level 10, animating with a duration of 2 seconds.
        mMap.animateCamera(CameraUpdateFactory.zoomTo(14), 2000, null);


    }

    public void showCrudOperationInfoDialog() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.customer_detail_crud_operation_title))
                .setMessage(getString(R.string.customer_detail_crud_operation_message))
                .show();
    }
}
