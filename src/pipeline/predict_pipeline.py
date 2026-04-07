"""
Car price prediction pipeline for UCPP.

Expects trained artifacts at:
    artifacts/model.pkl       — trained regression model
    artifacts/preprocessor.pkl — sklearn ColumnTransformer / Pipeline

These artifacts are produced by running the training pipeline.
Until a model is trained, the /api/predict-price endpoint returns a 503.
"""

import os
import sys
import pandas as pd

from src.exception import CustomException
from src.utils import load_object


class PredictPipeline:
    def __init__(self):
        pass

    def predict(self, features: pd.DataFrame):
        try:
            model_path       = os.path.join("artifacts", "model.pkl")
            preprocessor_path = os.path.join("artifacts", "preprocessor.pkl")

            if not os.path.exists(model_path):
                raise FileNotFoundError(
                    "Model artifact not found. Train the model first."
                )

            model        = load_object(model_path)
            preprocessor = load_object(preprocessor_path)

            data_scaled = preprocessor.transform(features)
            preds       = model.predict(data_scaled)
            return preds

        except FileNotFoundError:
            raise
        except Exception as e:
            raise CustomException(e, sys)


class CarData:
    """Holds user-supplied car attributes for a price prediction request."""

    NUMERIC_COLS     = ["year", "odometer"]
    CATEGORICAL_COLS = ["manufacturer", "model", "state", "transmission",
                        "cylinders", "drive", "fuel", "title_status"]

    def __init__(
        self,
        manufacturer: str,
        model: str,
        year: int,
        odometer: float,
        state: str,
        transmission: str = "",
        cylinders: str = "",
        drive: str = "",
        fuel: str = "",
        title_status: str = "clean",
    ):
        self.manufacturer = manufacturer
        self.model        = model
        self.year         = year
        self.odometer     = odometer
        self.state        = state
        self.transmission = transmission
        self.cylinders    = cylinders
        self.drive        = drive
        self.fuel         = fuel
        self.title_status = title_status

    def to_dataframe(self) -> pd.DataFrame:
        return pd.DataFrame([{
            "manufacturer": self.manufacturer,
            "model":        self.model,
            "year":         self.year,
            "odometer":     self.odometer,
            "state":        self.state,
            "transmission": self.transmission,
            "cylinders":    self.cylinders,
            "drive":        self.drive,
            "fuel":         self.fuel,
            "title_status": self.title_status,
        }])
