# Report testing results offline using Excel/CSV

This script provides the ability to easily report tests in offline, whenever you go the field and don't have internet/Jira access.

More info on this [blog post](https://www.getxray.app/blog/testing-in-offline-mode-using-xray-and-excel/).



## Usage

You would need to:
* generate/export an Excel for the tests you aim to execute. You can use [this template](https://store.getxporter.app/view/72?platf=JIRA8&cats=1) for the buit-in Document Generator ("docgen") or Xporter
* report the results on the Excel file
* export it to CSV
* use this Ruby-based script to submit results back to the Xray/Jira instance

### Script syntax
```
submit_results.rb --help
Usage: submit_results [options]
-u, --user USERNAME Jira username
-p, --pass PASSWORD Jira password
-j, --jira JIRA_BASE_URL Jira base URL
-c, --csv CSV_FILE CSV file
-s, --summary SUMMARY Test Execution summary
-d, --description DESCRIPTION Test Execution description
-v, --version VERSION Version
-r, --revision REVISION Revision
-t, --testplan TEST_PLAN Test Plan issue key
-e TEST_ENVIRONMENT, Test Environment
--environment
```

### Example

```
submit_results.rb  -j http://jiraserver.example.com  -u admin -p admin   -v v3.0 -r 123 -d "results reported in the field" -s "execution made inside the nuclear reactor" -c detailed_offline_results.csv
```

## License
[MIT](LICENSE)
