import type { MetaFunction } from "@remix-run/node";
import { redirect } from "@remix-run/node";
import { Link } from "@remix-run/react";

import { supabase } from "~/lib/supabase";

export async function loader() {
  let isSupabaseAvailable = true;

  try {
    // Test Supabase connection
    const { data, error } = await supabase.from('curriculum_works').select('count').limit(1).single();
    if (error) {
      isSupabaseAvailable = false;
    }
  } catch (error) {
    isSupabaseAvailable = false;
  }

  // For now, let's show the landing page instead of auto-redirect
  // if (isSupabaseAvailable) {
  //   return redirect("/login");
  // }

  return Response.json({ isSupabaseAvailable });
}

export const meta: MetaFunction = () => {
  return [
    { title: "딥독융합논술 ERP 시스템" },
    { name: "description", content: "딥독융합논술 franchise management system" },
  ];
};

export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <div className="text-2xl font-bold text-indigo-600">📚 딥독융합논술</div>
            </div>
            <div className="flex space-x-4">
              <Link 
                to="/login" 
                className="text-gray-700 hover:text-indigo-600 font-medium"
              >
                로그인
              </Link>
              <Link 
                to="/signup" 
                className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 font-medium"
              >
                회원가입
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 sm:text-5xl md:text-6xl">
            <span className="block">딥독융합논술</span>
            <span className="block text-indigo-600">ERP 시스템</span>
          </h1>
          <p className="mt-3 max-w-md mx-auto text-base text-gray-500 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
            독서논술 전문 프랜차이즈의 체계적인 학습 관리와 운영을 위한 통합 ERP 시스템입니다.
          </p>
        </div>

        {/* Features */}
        <div className="mt-16">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="mx-auto h-12 w-12 text-indigo-600 text-2xl mb-4">👨‍🎓</div>
              <h3 className="text-lg font-medium text-gray-900">학생 관리</h3>
              <p className="mt-2 text-base text-gray-500">
                88작품 체계적 진도관리<br />
                개별 학습 현황 추적
              </p>
            </div>
            <div className="text-center">
              <div className="mx-auto h-12 w-12 text-indigo-600 text-2xl mb-4">📊</div>
              <h3 className="text-lg font-medium text-gray-900">운영 관리</h3>
              <p className="mt-2 text-base text-gray-500">
                매출 분석 및 리포팅<br />
                지점별 성과 관리
              </p>
            </div>
            <div className="text-center">
              <div className="mx-auto h-12 w-12 text-indigo-600 text-2xl mb-4">💬</div>
              <h3 className="text-lg font-medium text-gray-900">소통 시스템</h3>
              <p className="mt-2 text-base text-gray-500">
                학부모 상담 관리<br />
                알림톡 자동 발송
              </p>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-16 text-center">
          <Link 
            to="/login"
            className="inline-flex items-center px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 md:py-4 md:text-lg md:px-10"
          >
            시스템 시작하기
          </Link>
        </div>

        {/* Curriculum Info */}
        <div className="mt-16 bg-white rounded-lg shadow-lg p-8">
          <h2 className="text-2xl font-bold text-gray-900 text-center mb-8">
            88작품 체계적 커리큘럼
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div className="text-center p-4 bg-red-50 rounded-lg">
              <h3 className="font-semibold text-red-700">A단계 (16작품)</h3>
              <p className="text-sm text-red-600 mt-2">기초 외국 고전</p>
              <p className="text-xs text-gray-600 mt-1">톰소여의모험, 빨간머리앤 등</p>
            </div>
            <div className="text-center p-4 bg-blue-50 rounded-lg">
              <h3 className="font-semibold text-blue-700">B단계 (17작품)</h3>
              <p className="text-sm text-blue-600 mt-2">한국 고전</p>
              <p className="text-xs text-gray-600 mt-1">흥부전, 심청전, 홍길동전 등</p>
            </div>
            <div className="text-center p-4 bg-green-50 rounded-lg">
              <h3 className="font-semibold text-green-700">C단계 (43작품)</h3>
              <p className="text-sm text-green-600 mt-2">심화 세계 문학</p>
              <p className="text-xs text-gray-600 mt-1">어린왕자, 노인과바다, 레미제라블 등</p>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-lg">
              <h3 className="font-semibold text-purple-700">D단계 (12작품)</h3>
              <p className="text-sm text-purple-600 mt-2">한국 근현대</p>
              <p className="text-xs text-gray-600 mt-1">꺼삐딴리, 소나기, 메밀꽃필무렵 등</p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-16">
        <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
          <p className="text-center text-sm text-gray-500">
            &copy; {new Date().getFullYear()} 딥독융합논술 ERP. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
