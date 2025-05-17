import pandas as pd 
import numpy as np 
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBRegressor
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from tqdm import tqdm
from joblib import Parallel, delayed
from multiprocessing import Pool, cpu_count
import os
from scipy.stats import norm
#------------------------------------------------------------------#
# Generating macros/lists with variable names for different models #
#------------------------------------------------------------------#

data = pd.read_stata('~/Kenya_NDMA_MUAC_ward_level_pre_and_post_2016_for_Python.dta') ## CHANGE FOR LOCAL DIRECTORY

print(type(data))
#print(list(data.columns))

label_encoder = LabelEncoder()
data['time_cont_enc'] = label_encoder.fit_transform(data['time_cont']) #encoding time var

#------------------------------------------------------------------#
# Generating macros/lists with variable names for different models #
#------------------------------------------------------------------#
static = ['crop_mask_1km',  'rangeland_mask_1km',  'remoteness', 'elevation_1km', 'pop_den_1km',  'LHZ_max_area']
l_year = [col for col in data if col.startswith('lyear_')]

globals_dict = globals()
for i in range(1,24):
    globals_dict[f"l{i}"] = [col for col in data if col.startswith('l'+ str(i)+'_')]

#------------------------------------------------------------------#
# Generating datasets for each predictive horizon #
#------------------------------------------------------------------#
# FUll- feature model #

ff_m1 = static + l_year + l1 + l2 + l3 
ff_m3 = static + l_year + l4 + l5 + l6 
ff_m6 = static + l_year + l7 + l8 + l9  
ff_m9 = static + l_year + l10 + l11 + l12 
ff_m12 = static + l_year + l13 + l14 + l15 

# Hybrid model #
# Wasting #

hb_m1  = static + l_year + l1 + l2 + l3 + ['wlag1', 'wlag2' , 'wlag3']
hb_m3  = static + l_year + l4 + l5 + l6 + ['wlag4', 'wlag5' , 'wlag6']
hb_m6  = static + l_year + l7 + l8 + l9 + ['wlag7', 'wlag8' , 'wlag9']
hb_m9  = static + l_year + l10 + l11 + l12 + ['wlag10', 'wlag11' , 'wlag12']
hb_m12 = static + l_year + l13 + l14 + l15 + ['wlag13', 'wlag14' , 'wlag15']


# Naive model #

nv_m1  = ['wlag1', 'wlag2' , 'wlag3']
nv_m3  = ['wlag4', 'wlag5' , 'wlag6']
nv_m6  = ['wlag7', 'wlag8' , 'wlag9']
nv_m9  = ['wlag10', 'wlag11' , 'wlag12']
nv_m12 = ['wlag13', 'wlag14' , 'wlag15']


# dataset for hyperparameter tunning
data_ht = data[data["training_sample"] == 2] #getting the training/testing dataset (20% of the total one)

# validation dataset
data_val = data[data["training_sample"] == 1] #getting the training/validation dataset (80% of the total one)

#----------------------------------------------------------------------#
#  Scatter/ Non-parametric regression of wasting prevalence through time
#----------------------------------------------------------------------#

plt.scatter(data_val["time_cont_enc"], data_val["wasting"],  alpha=0.5)
plt.xticks(np.arange(min(data_val["time_cont_enc"]), max(data_val["time_cont_enc"])+1, 10.0))
plt.show()

#----------------------------------------------------------------------#
#  Walking-forward training and predicting
#----------------------------------------------------------------------#
#split the dataset in sliding training windows

def train_test_split(data_train, data_test, n_test, pred_h):
    i = n_test-36
    t = n_test + pred_h
    print("lower period {}, upper period {}, predict period {}".format(i, n_test,t))
    
    mask = (data_train['time_cont_enc']<n_test) & (data_train['time_cont_enc']>=i)
    
    return data[mask], data_test[data_test['time_cont_enc'] == t]

#------------------------------
num_cpus = os.cpu_count()

def bootstrap_iteration(model,train, testX, ff_m, num_iterations):
    all_predictions = np.zeros((num_iterations, testX.shape[0]))

    def single_bootstrap_iteration(iteration):
        resampled_data = train.groupby('time_cont_enc', group_keys=False).apply(
            lambda x: x.sample(frac=1, replace=True))

        X_sampled = resampled_data[[c for c in trainX.columns if c in ff_m]]
        y_sampled = resampled_data['wasting']

        model.fit(X_sampled, y_sampled)
        y_pred = model.predict(testX)

        return y_pred

    # Parallelize the bootstrap iterations
    all_predictions = Parallel(n_jobs=num_cpus)(
        delayed(single_bootstrap_iteration)(i) for i in tqdm(range(num_iterations))
    )

    return np.array(all_predictions)

#---------------------------------------------------------------------
ph = [1,3,6,9,12]
model_name = ['hb']

for m in model_name:
    for ph in ph:
        globals()[f'predictions_{ph}'] = pd.DataFrame()
        df_yhat = pd.DataFrame()
        globals()[f'feat_imp{ph}'] = pd.DataFrame()
        globals()[f'feat_imp{ph}']['var_names'] = globals()[f'{m}_m{ph}']

        for a in sorted(data_val["time_cont_enc"].unique()):
            if a + ph > data_val["time_cont_enc"].max():
                break

            if a > 2:
                train, predict = train_test_split(data, data_val, a, ph)
                trainX = train[[c for c in train.columns if c in globals()[f'{m}_m{ph}']]]
                trainY = train['wasting']

                testX = predict[[c for c in predict.columns if c in globals()[f'{m}_m{ph}']]]
                testY = predict['wasting']

                model = XGBRegressor(n_estimators=1000, max_depth=7, eta=0.1,
                                    subsample=0.9, colsample_bylevel=1, seed=12345)

                
                model.fit(trainX, trainY)
        
        #getting feature importance
                fi =  pd.DataFrame(data = model.feature_importances_, columns = ['fi'+ str(a)])
                globals()[f'feat_imp{ph}'] = pd.concat([globals()[f'feat_imp{ph}'], fi], axis=1)
    
    
        # this is prediction
                yhat = model.predict(testX)

                num_iterations = 1000
                all_predictions = bootstrap_iteration(model, train, testX, globals()[f'{m}_m{ph}'], num_iterations)

                lower_bound = np.percentile(all_predictions, 5, axis=0)
                upper_bound = np.percentile(all_predictions, 95, axis=0)

                df_yhat = pd.DataFrame(data={'yhat': yhat,  
                                            'lower_bound': lower_bound,
                                            'upper_bound': upper_bound}, index=testX.index.copy())

                df_yhat['yhat'] = np.where(df_yhat.yhat < 0, 0, df_yhat.yhat)
                df_out = pd.merge(testY, df_yhat, how='left', left_index=True, right_index=True)
                df_out = df_out.join(predict["ward_polygon_ID"])
                df_out = df_out.join(predict["time_cont_enc"])
                df_out = df_out.join(predict["time_cont"])


                globals()[f'predictions_{ph}'] = pd.concat([globals()[f'predictions_{ph}'], df_out], ignore_index=True)
                filename = f'~Wasting_prediction_{m}_{ph}.csv' ## CHANGE FOR LOCAL DIRECTORY
                globals()[f'predictions_{ph}'].to_csv(filename, index=False)

#---------------------------------------------------------------------
# Truncated gaussian smoothing
#---------------------------------------------------------------------
def smooth_per_group(df, sigma, columns_to_smooth):
    smoothed_df = df.copy()
    window_size = int(3 * sigma) # Size of the Gaussian kernel (3 sigma covers over 99% of the curve)
    
    # Generate Gaussian kernel weights for the past values including current point (one-sided)
    # Note: We generate a kernel for each possible window size to ensure proper normalization at the start of the series
    kernels = {i: norm.pdf(np.arange(i, -1, -1), 0, sigma) for i in range(window_size + 1)}

    for unit_id in df['ward_polygon_ID'].unique():
        unit_data = df[df['ward_polygon_ID'] == unit_id].sort_values(by='time_cont_enc')       
        for col in columns_to_smooth:
            smoothed_col_name = f'{col}_smoothed'
            smoothed_values = np.zeros_like(unit_data[col].values)

            # One-sided Gaussian smoothing
            for i in range(len(unit_data)):
                # Determine the window size (less at the start of the series)
                current_window_size = min(i, window_size) + 1
                kernel = kernels[current_window_size - 1]
                kernel = kernel / kernel.sum()  # Normalize the kernel weights to sum to 1

                smoothed_values[i] = np.dot(unit_data[col].values[i - current_window_size + 1 : i + 1], kernel)
            
            smoothed_df.loc[unit_data.index, smoothed_col_name] = smoothed_values
    
    return smoothed_df


columns_to_smooth = ['wasting','yhat', 'lower_bound', 'upper_bound']
ph_list = [1,3,6]
model_names = ['ff', 'hb', 'nv']

for m in model_names:
    for ph in ph_list:
        read_filename = f'~Wasting_prediction_{m}_{ph}.csv' ## CHANGE FOR LOCAL DIRECTORY
        final_df = pd.read_csv(read_filename)
        final_df_smoothed = smooth_per_group(final_df, sigma=3, columns_to_smooth=columns_to_smooth)
        save_filename = f'~Smoothed_Wasting_prediction_{m}_{ph}.csv' ## CHANGE FOR LOCAL DIRECTORY
        final_df_smoothed.to_csv(save_filename, index=False)



