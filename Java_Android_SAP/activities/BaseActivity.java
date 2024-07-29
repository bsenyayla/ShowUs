package com.san.sniper.activities;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import com.san.sniper.AppDatabase;
import com.san.sniper.ContextWrapper;
import com.san.sniper.R;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import retrofit2.Call;


public class BaseActivity extends AppCompatActivity {
    private ProgressDialog progressDialog;
    private List<Call> callList = new ArrayList<>();
    private List<AsyncTask> asyncTasks = new ArrayList<>();
    CompositeDisposable compositeDisposable = new CompositeDisposable();
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initializeProgressDialog();
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(ContextWrapper.wrap(newBase));
    }

    private void initializeProgressDialog() {
        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage(getString(R.string.please_wait));
    }

    public final void showProgressDialog(){
        showProgressDialog(true);
    }

    public final void showProgressDialog(boolean isCancellable){
        if (!BaseActivity.this.isFinishing()) {
            if (progressDialog == null) {
                initializeProgressDialog();
            }
            progressDialog.setCancelable(false);
            progressDialog.show();
        }
    }

    public final void hideProgressDialog(){
        if (!BaseActivity.this.isFinishing()) {
            if (progressDialog == null) {
                return;
            }
            progressDialog.dismiss();
        }
    }

    public final void addCall(Call call){
        callList.add(call);
    }
    public final void addDisposable(Disposable disposable){
        compositeDisposable.add(disposable);
    }
    public final AppDatabase getDatabase(){
        return AppDatabase.getAppDatabase(this);
    }

    protected void addAsyncTask(AsyncTask asyncTask){
        asyncTasks.add(asyncTask);
    }

    @Override
    protected void onDestroy() {
        for (Call call: callList){
            if (call.isExecuted() && !call.isCanceled()){
                call.cancel();
            }
        }
        for (AsyncTask asyncTask:asyncTasks){
            if (asyncTask.getStatus() == AsyncTask.Status.FINISHED){
                asyncTask.cancel(true);
            }
        }

        compositeDisposable.clear();
        super.onDestroy();
    }

    public void showError(String error) {
        Toast.makeText(this, error, Toast.LENGTH_LONG).show();
    }

    public AlertDialog.Builder getWarningDialogBuilder(String message){
        return getDialogBuilder(getString(R.string.title_warning),message);
    }
    public AlertDialog.Builder getDialogBuilder(String title,String message){
        return new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(message);
    }

    public static void hideKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        View view = activity.getCurrentFocus();
        if (view == null) {
            view = new View(activity);
        }
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    public static void showKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        View view = activity.getCurrentFocus();
        if (view == null) {
            view = new View(activity);
        }
        imm.toggleSoftInputFromWindow(view.getWindowToken(), InputMethodManager.SHOW_FORCED,0);
    }

    public ProgressDialog getProgressDialog() {
        return progressDialog;
    }
}
