/*
*
* Copyright 2013 Telefonica Investigacion y Desarrollo, S.A.U
*
* This file is part of Orion Context Broker.
*
* Orion Context Broker is free software: you can redistribute it and/or
* modify it under the terms of the GNU Affero General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Orion Context Broker is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
* General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
*
* For those usages not covered by this license please contact with
* fermin at tid dot es
*
* Author: Ken Zangelin
*/
#include "gtest/gtest.h"

#include "logMsg/logMsg.h"
#include "logMsg/traceLevels.h"

#include "ngsi/StatusCode.h"
#include "ngsi/ErrorCode.h"
#include "ngsi9/NotifyContextAvailabilityResponse.h"



/* ****************************************************************************
*
* all - 
*/
TEST(NotifyContextAvailabilityResponse, all)
{
  StatusCode                         sc(SccBadRequest, "status", "status details");
  ErrorCode                          ec(SccForbidden,  "error",  "error details");
  NotifyContextAvailabilityResponse  ncr1;
  NotifyContextAvailabilityResponse  ncr2(sc);
  NotifyContextAvailabilityResponse  ncr3(ec);
  
  EXPECT_EQ(ncr1.responseCode.code, SccOk);
  EXPECT_EQ(ncr2.responseCode.code, SccBadRequest);
  EXPECT_EQ(ncr3.responseCode.code, SccForbidden);

  ncr1.render(NotifyContextAvailability, XML, "");
  ncr1.present("");
  ncr1.release();
}
