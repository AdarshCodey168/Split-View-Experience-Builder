Overview
This project provides a custom split-view list solution for Salesforce Communities, enhancing navigation and record management for community users. Since Salesforce does not natively offer a split-view list in Experience Cloud, this solution mimics the behavior while maintaining security and usability.

Features
Refresh: Ensures the list is always updated with the latest records.
Sorting: Allows sorting records by specific fields.
Picklist Filtering: Uses a custom picklist field (e.g., Status) to filter records.
Object-Agnostic: Can be used with any Salesfoce object
Editable Form: Opens a form for easy updates while displaying non-editable fields as needed.

Current Enhancements & Fixes
Fixing an issue with the currency field in the form.
Ensuring data updates reflect immediately in the left panel after saving.
Adding toast notifications for save actions.

Installation Steps
Option 1: Clone the Repository (Recommended)

Option 2: Manual Deployment
Deploy Apex Class, LMS, and LWC components before configuring the UI.

Create a Standard Page with a two-column layout (1:2 ratio).
Add Components:
Drag & drop SplitView Component in the left column.
Drag & drop DualRecordForm Component in the right column.
Save the page.
Use the Components:
Fill all input fields on both components.
Ensure that Field API Names are comma-separated for defining:
Fields to be displayed.
Fields to be editable.
Read-only fields.

Usage Guidelines
Designed for Salesforce Community/Experience Cloud.
Works with any Salesforce object by defining API names in the configuration.
Ensure that the necessary LWC, Apex, and LMS components are deployed before use.


