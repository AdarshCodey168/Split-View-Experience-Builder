# Custom Split-View List for Salesforce Communities

## Overview
This project provides a **custom split-view list** solution for Salesforce **Experience Cloud (Communities)**, enhancing navigation and record management for community users. Since Salesforce does not natively offer a split-view list in Experience Cloud, this solution replicates its behavior while maintaining **security and usability**.

## Features
- **Real-time Refresh**: Ensures the list always displays the latest records.
- **Sorting**: Allows users to sort records by specific fields.
- **Picklist Filtering**: Uses a custom picklist field (e.g., `Status`) to filter records.
- **Object-Agnostic**: Works with any Salesforce object.
- **Editable Form**: Opens a form for quick updates, while keeping non-editable fields visible.

## Upcoming Enhancements & Fixes
- Fix an issue with the **currency field** in the form.
- Ensure that data updates **immediately reflect** in the left panel after saving.
- Add **toast notifications** for save actions.

---

## Installation

### Option 1: Clone the Repository (Recommended)
1. Open your terminal and run:
   ```sh
   git clone https://github.com/your-repository/split-view-list.git
   cd split-view-list
   ```
2. Deploy the components to your Salesforce org using **Salesforce CLI**:
   ```sh
   sfdx force:source:push -u YOUR_ORG_ALIAS
   ```

### Option 2: Manual Deployment
1. Deploy the following components manually:
   - **Apex Classes**
   - **Lightning Message Service (LMS)**
   - **Lightning Web Components (LWC)**
2. Configure the UI:
   - Create a **Standard Page** with a **two-column layout (1:2 ratio)**.
   - Drag & Drop:
     - **`SplitView` Component** in the left column.
     - **`DualRecordForm` Component** in the right column.
   - Save the page.

---

## Usage Guidelines
- Designed for **Salesforce Community/Experience Cloud**.
- Works with **any Salesforce object** by defining **API names** in the configuration.
- Before use, ensure that the necessary **LWC, Apex, and LMS** components are deployed.
- To define fields:
  - Use **comma-separated Field API Names** for:
    - Fields to be displayed.
    - Fields to be editable.
    - Read-only fields.

---

## Contributing
We welcome contributions! Feel free to **fork** this repository, create a new branch, and submit a **pull request**.

---

## License
This project is licensed under the **MIT License**.

---

## Support
For any questions or issues, please open an **issue** in this repository or reach out via **Salesforce Trailblazer Community**.

