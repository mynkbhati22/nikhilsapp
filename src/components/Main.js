import React, { useState } from "react";
import {
  MDBContainer,
  MDBNavbar,
  MDBNavbarBrand,
  MDBNavbarToggler,
  MDBIcon,
  MDBNavbarNav,
  MDBNavbarItem,
  MDBNavbarLink,
  MDBBtn,
  MDBDropdown,
  MDBDropdownToggle,
  MDBDropdownMenu,
  MDBDropdownItem,
  MDBDropdownLink,
  MDBCollapse,
  MDBInputGroup,
  MDBTable,
  MDBTableHead,
  MDBTableBody,
} from "mdb-react-ui-kit";
import { Container } from "@mui/system";

export default function Main() {
  const [showBasic, setShowBasic] = useState(false);

  return (
    // NAVBAR
    <>
      <MDBNavbar expand="lg" light bgColor="light">
        <MDBContainer fluid>
          <MDBNavbarBrand href="#">Brand</MDBNavbarBrand>

          <MDBNavbarToggler
            aria-controls="navbarSupportedContent"
            aria-expanded="false"
            aria-label="Toggle navigation"
            onClick={() => setShowBasic(!showBasic)}
          >
            <MDBIcon icon="bars" fas />
          </MDBNavbarToggler>

          <MDBCollapse navbar show={showBasic}>
            <MDBNavbarNav className="mr-auto mb-2 mb-lg-0">
              <MDBNavbarItem>
                <MDBNavbarLink active aria-current="page" href="#">
                  Home
                </MDBNavbarLink>
              </MDBNavbarItem>
              <MDBNavbarItem>
                <MDBNavbarLink href="#">Link</MDBNavbarLink>
              </MDBNavbarItem>

              <MDBNavbarItem>
                <MDBDropdown>
                  <MDBDropdownToggle tag="a" className="nav-link">
                    Dropdown
                  </MDBDropdownToggle>
                  <MDBDropdownMenu>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Action</MDBDropdownLink>
                    </MDBDropdownItem>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Another action</MDBDropdownLink>
                    </MDBDropdownItem>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Something else here</MDBDropdownLink>
                    </MDBDropdownItem>
                  </MDBDropdownMenu>
                </MDBDropdown>
              </MDBNavbarItem>

              <MDBNavbarItem>
                <MDBNavbarLink
                  disabled
                  href="#"
                  tabIndex={-1}
                  aria-disabled="true"
                >
                  Disabled
                </MDBNavbarLink>
              </MDBNavbarItem>
            </MDBNavbarNav>

            <MDBInputGroup
              tag="form"
              className="d-flex w-auto align-items-center"
            >
              <input
                className="form-control"
                placeholder="Type query"
                aria-label="Search"
                type="Search"
              />
              <MDBBtn outline className="mx-2">
                Search
              </MDBBtn>
            </MDBInputGroup>
          </MDBCollapse>
        </MDBContainer>
      </MDBNavbar>
      {/* TABLE */}
      <Container maxWidth="lg">
        <MDBTable style={{ marginTop: "50px", border: "1px solid" }}>
          <MDBTableHead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">First</th>
              <th scope="col">Last</th>
              <th scope="col">Handle</th>
            </tr>
          </MDBTableHead>
          <MDBTableBody>
            <tr>
              <th scope="row">1</th>
              <td>Mark</td>
              <td>Otto</td>
              <td>@mdo</td>
            </tr>
            <tr>
              <th scope="row">2</th>
              <td>Jacob</td>
              <td>Thornton</td>
              <td>@fat</td>
            </tr>
            <tr>
              <th scope="row">3</th>
              <td colSpan={2}>Larry the Bird</td>
              <td>@twitter</td>
            </tr>
          </MDBTableBody>
        </MDBTable>
      </Container>
    </>
  );
}
