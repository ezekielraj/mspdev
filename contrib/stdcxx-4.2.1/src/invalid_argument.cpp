/***************************************************************************
 *
 * invalid_argument.cpp - definitions of class invalid_argument members
 *
 * $Id: invalid_argument.cpp 580483 2007-09-28 20:55:52Z sebor $
 *
 ***************************************************************************
 *
 * Licensed to the Apache Software  Foundation (ASF) under one or more
 * contributor  license agreements.  See  the NOTICE  file distributed
 * with  this  work  for  additional information  regarding  copyright
 * ownership.   The ASF  licenses this  file to  you under  the Apache
 * License, Version  2.0 (the  "License"); you may  not use  this file
 * except in  compliance with the License.   You may obtain  a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the  License is distributed on an  "AS IS" BASIS,
 * WITHOUT  WARRANTIES OR CONDITIONS  OF ANY  KIND, either  express or
 * implied.   See  the License  for  the  specific language  governing
 * permissions and limitations under the License.
 *
 **************************************************************************/

#define _RWSTD_LIB_SRC

#include <stdexcept>
#include <rw/_defs.h>


_RWSTD_NAMESPACE (std) {

// outlined to avoid generating a vtable in each translation unit
// that uses the class
/* virtual */ invalid_argument::
~invalid_argument () _THROWS (())
{
    // no-op
}

}   // namespace std
