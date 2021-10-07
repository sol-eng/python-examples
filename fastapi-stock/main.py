# -*- coding: utf-8 -*-
import os
from datetime import date
from typing import List

import numpy as np
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

prices = pd.read_csv(
    os.path.join(os.path.dirname(__file__), "prices.csv"),
    index_col=0,
    parse_dates=True,
)


def validate_ticker(ticker):
    if ticker not in prices["ticker"].unique():
        raise HTTPException(status_code=404, detail="Ticker not found")


class Tickers(BaseModel):
    tickers: list = Field(title="All available stock tickers")


class Stock(BaseModel):
    ticker: str = Field(..., title="Ticker of the stock")
    price: float = Field(..., title="Latest price of the stock")
    volatility: float = Field(..., title="Latest volatility of the stock price")


class Price(BaseModel):
    date: date
    high: float = Field(..., title="High price for this date")
    low: float = Field(..., title="Low price for this date")
    close: float = Field(..., title="Closing price for this date")
    volume: int = Field(..., title="Daily volume for this date")
    adjusted: float = Field(..., title="Split-adjusted price for this date")


app = FastAPI(
    title="Stocks API",
    description="The Stocks API provides pricing and volatility data for a "
    "limited number of US equities from 2010-2018",
)


@app.get("/stocks", response_model=Tickers)
async def tickers():
    tickers = prices["ticker"].unique().tolist()
    return {"tickers": tickers}


@app.get("/stocks/{ticker}", response_model=Stock)
async def ticker(ticker: str):
    validate_ticker(ticker)

    ticker_prices = prices[prices["ticker"] == ticker]
    current_price = ticker_prices["close"].last("1d").round(2)
    current_volatility = np.log(
        ticker_prices["adjusted"] / ticker_prices["adjusted"].shift(1)
    ).var()

    return {
        "ticker": ticker,
        "price": current_price,
        "volatility": current_volatility,
    }


@app.get("/stocks/{ticker}/history", response_model=List[Price])
async def history(ticker: str):
    validate_ticker(ticker)

    ticker_prices = prices[prices["ticker"] == ticker]
    ticker_prices["date"] = ticker_prices.index
    return ticker_prices.to_dict("records")
