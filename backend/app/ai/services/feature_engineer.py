import os
import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split


class FeatureEngineer:
    SAFE_FEATURES = [
        'planned_duration_days',
        'estimated_hours',
        'priority_id',
        'department_id',
        'is_cross_functional',
        'num_assigned_employees',
        'budget_allocated',
        'budget_spent',
        'budget_remaining',
        'budget_ratio',
        'risk_count',
        'critical_risk_count',
        'active_risk_count',
        'unmitigated_risk_count',
        'max_risk_score',
        'avg_risk_score',
        'mitigation_count',
        'completed_mitigation_count',
        'overdue_mitigation_count',
        'mitigation_completion_rate',
        'overdue_mitigation_rate',
        'has_dependencies',
        'num_dependencies',
        'num_blocking_deps',
        'num_satisfied_deps',
        'fs_count',
        'ss_count',
        'ff_count',
        'sf_count',
        'max_dep_lag_days',
        'avg_employee_active_tasks',
        'max_employee_active_tasks',
        'avg_employee_overdue_tasks',
        'max_employee_overdue_tasks',
        'avg_employee_estimated_hours',
        'max_employee_estimated_hours',
        'understaffed',
        'overloaded',
        'department_workload',
        'initiative_is_active',
        'initiative_days_remaining',
        'sibling_tasks_count',
        'sibling_delayed_pct',
        'is_pending_no_staff',
        'is_pending_dep_blocked',
        'is_pending_manager',
        'is_ready_awaiting',
        'dept_on_time_rate',
        'dept_delay_rate',
        'dept_avg_delay_days',
        'comment_count',
    ]

    CATEGORICAL_FEATURES = ['priority_id', 'department_id']

    def __init__(self):
        self.numerical_features = []
        self.categorical_features = []
        self.feature_order = []
        self.preprocessor = None
        self.is_fitted = False

    def prepare_data(self, df, target_col='is_delayed', test_size=0.2, random_state=42):
        if df is None or df.empty:
            raise ValueError("Empty dataframe")
        if target_col not in df.columns:
            raise ValueError(f"Target column '{target_col}' not found")

        self.feature_order = [c for c in self.SAFE_FEATURES if c in df.columns]
        missing = [c for c in self.SAFE_FEATURES if c not in df.columns]

        if missing:
            print(f"[FeatureEngineer] Missing features ({len(missing)}): {missing[:5]}")
        if not self.feature_order:
            raise ValueError("No safe features available in dataframe")

        self._identify_features()

        X = df[self.feature_order].copy()
        y = df[target_col].astype(int)

        numeric_cols = X.select_dtypes(include=[np.number]).columns
        if len(numeric_cols):
            medians = X[numeric_cols].median()
            X[numeric_cols] = X[numeric_cols].fillna(medians)
        X = X.replace([np.inf, -np.inf], 0)

        y_counts = pd.Series(y).value_counts()

        if len(y_counts) >= 2 and y_counts.min() >= 2:
            X_train, X_test, y_train, y_test = train_test_split(
                X, y,
                test_size=test_size,
                random_state=random_state,
                stratify=y,
            )
        else:
            X_train, X_test, y_train, y_test = train_test_split(
                X, y,
                test_size=test_size,
                random_state=random_state,
            )

        self._build_preprocessor()
        X_train_p = self.preprocessor.fit_transform(X_train)
        X_test_p = self.preprocessor.transform(X_test)
        self.is_fitted = True

        print(f"[FeatureEngineer] train={len(X_train)} test={len(X_test)} features={len(self.feature_order)}")
        print(f"[FeatureEngineer] target_distribution={dict(y_counts)}")

        return X_train_p, X_test_p, y_train, y_test

    def transform_single(self, features_dict):
        if not self.is_fitted:
            raise ValueError("FeatureEngineer not fitted")

        row = {c: features_dict.get(c, 0) for c in self.feature_order}
        df = pd.DataFrame([row])
        return self.preprocessor.transform(df)

    def _identify_features(self):
        self.categorical_features = [c for c in self.feature_order if c in self.CATEGORICAL_FEATURES]
        self.numerical_features = [c for c in self.feature_order if c not in self.CATEGORICAL_FEATURES]

    def _build_preprocessor(self):
        num_pipe = Pipeline([('scaler', StandardScaler())])
        cat_pipe = Pipeline([('onehot', OneHotEncoder(handle_unknown='ignore', sparse_output=False))])

        transformers = []
        if self.numerical_features:
            transformers.append(('num', num_pipe, self.numerical_features))
        if self.categorical_features:
            transformers.append(('cat', cat_pipe, self.categorical_features))

        self.preprocessor = ColumnTransformer(transformers, remainder='drop')

    def get_feature_names(self):
        if not self.is_fitted:
            return []
        try:
            return self.preprocessor.get_feature_names_out().tolist()
        except Exception:
            return []

    def save(self, filepath):
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        joblib.dump({
            'preprocessor': self.preprocessor,
            'numerical': self.numerical_features,
            'categorical': self.categorical_features,
            'feature_order': self.feature_order,
            'fitted': self.is_fitted,
        }, filepath)
        print(f"[FeatureEngineer] saved={filepath}")

    def load(self, filepath):
        if not os.path.exists(filepath):
            return False
        try:
            data = joblib.load(filepath)
            self.preprocessor = data['preprocessor']
            self.numerical_features = data['numerical']
            self.categorical_features = data['categorical']
            self.feature_order = data.get('feature_order', [])
            self.is_fitted = data['fitted']
            return True
        except Exception as e:
            print(f"[FeatureEngineer] load_failed={e}")
            return False
