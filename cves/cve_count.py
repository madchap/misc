import requests
import gzip
import json
import csv
from collections import OrderedDict

def get_cve_data(year):
    url = f'https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-{year}.json.gz'
    response = requests.get(url)
    if response.status_code == 200:
        return gzip.decompress(response.content).decode('utf-8')
    else:
        return None

def get_total_cves_per_month(start_year, end_year):
    cves_per_month = {}

    for year in range(start_year, end_year + 1):
        print(f"Processing year {year}")
        cves_data = get_cve_data(year)
        if cves_data:
            cves_json = json.loads(cves_data)
            cve_items = cves_json.get('CVE_Items', [])
            for item in cve_items:
                published_date = item['publishedDate']
                month_year = published_date[:7]  # Extract the year and month in YYYY-MM format
                cves_per_month[month_year] = cves_per_month.get(month_year, 0) + 1

    # Sort the cves_per_month dictionary by year and month
    sorted_cves_per_month = OrderedDict(sorted(cves_per_month.items()))

    # Calculate the cumulative CVEs
    cumulative_cves = 0
    for month, count in sorted_cves_per_month.items():
        cumulative_cves += count
        sorted_cves_per_month[month] = (count, cumulative_cves)

    return sorted_cves_per_month

def save_cves_to_csv(cves_per_month, output_file):
    with open(output_file, mode='w', newline='') as csvfile:
        fieldnames = ['Month', 'CVEs Created', 'Cumulative CVEs']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        cumulative_cves = 0
        for month, counts in cves_per_month.items():
            count, cumulative_cves = counts
            writer.writerow({'Month': month, 'CVEs Created': count, 'Cumulative CVEs': cumulative_cves})

if __name__ == '__main__':
    start_year = 2010
    end_year = 2023  # Replace with the current year if needed
    output_file = 'cves_per_month.csv'

    cves_per_month = get_total_cves_per_month(start_year, end_year)
    save_cves_to_csv(cves_per_month, output_file)

    print(f'CSV file "{output_file}" with CVEs per month and cumulative CVEs has been generated.')
