import json, math, csv

# 自造样例数据：12 个月度收益率（%），虚构，非真实行情
raw = {
    "600519.SH": [2.1, -3.4, 1.8, 4.2, -1.5, 2.7, 0.9, 3.3, -2.1, 1.4, 5.0, -0.8],
    "00700.HK": [3.5, 1.2, -4.1, 2.6, 5.3, -2.2, 0.8, 4.4, 1.9, -3.7, 2.2, 6.1],
    "AAPL.US":  [1.8, 2.4, -1.6, 3.1, 0.5, 4.7, -2.8, 1.2, 3.9, -0.4, 2.6, 1.1],
}
def mean(x): return sum(x)/len(x)
def std(x, ddof=1):
    m = mean(x); return math.sqrt(sum((v-m)**2 for v in x)/(len(x)-ddof))
def corr(a, b):
    ma, mb = mean(a), mean(b)
    cov = sum((x-ma)*(y-mb) for x,y in zip(a,b))/(len(a)-1)
    return cov/(std(a)*std(b))

codes = list(raw)
r = {c: [v/100.0 for v in raw[c]] for c in codes}
out = {}
for c in codes:
    rs = r[c]
    cum, prod = 1.0, [1.0]
    for v in rs:
        cum *= (1+v); prod.append(cum)
    ann_ret = prod[-1] - 1            # 12 个月 = 1 年，无需再开方
    ann_vol = std(rs)*math.sqrt(12)
    peak = prod[0]; mdd = 0.0
    for p in prod[1:]:
        peak = max(peak, p); mdd = min(mdd, (p-peak)/peak)
    out[c] = dict(ann_return_pct=round(ann_ret*100,2), ann_vol_pct=round(ann_vol*100,2),
                  max_dd_pct=round(mdd*100,2),
                  worst_month=f"M{rs.index(min(rs))+1}({min(raw[c]):+.1f}%)")

w = 1/3
codes_list=[r[x] for x in codes]
covmat=[]
for ra in codes_list:
    covmat.append([sum((a-mean(ra))*(b-mean(rb)) for a,b in zip(ra,rb))/(len(ra)-1) for rb in codes_list])
port_m = math.sqrt(sum(w*w*covmat[i][j] for i in range(3) for j in range(3)))
out["PORTFOLIO_EW"] = dict(ann_vol_pct=round(port_m*math.sqrt(12)*100,2),
    pair_corr={f"{a}~{b}": round(corr(r[a], r[b]),3)
               for a,b in [("600519.SH","00700.HK"),("600519.SH","AAPL.US"),("00700.HK","AAPL.US")]})
print(json.dumps(out, indent=1, ensure_ascii=False))
with open("stock_monthly_returns_sample.csv","w",newline="") as f:
    wr = csv.writer(f); wr.writerow(["code"]+[f"M{i+1}" for i in range(12)]); 
    for c in codes: wr.writerow([c]+raw[c])
print("csv ok")
